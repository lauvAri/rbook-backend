package com.csu.r_book.modules.coderunner.service.impl;

import com.csu.r_book.modules.coderunner.component.RScriptExecutor;
import com.csu.r_book.modules.coderunner.config.CodeRunnerProperties;
import com.csu.r_book.modules.coderunner.model.dto.*;
import com.csu.r_book.modules.coderunner.model.entity.ChapterEntity;
import com.csu.r_book.modules.coderunner.model.entity.ExecutionLogEntity;
import com.csu.r_book.modules.coderunner.model.entity.RScriptEntity;
import com.csu.r_book.modules.coderunner.model.entity.ScriptVariableEntity;
import com.csu.r_book.modules.coderunner.repository.ChapterRepository;
import com.csu.r_book.modules.coderunner.repository.ExecutionLogRepository;
import com.csu.r_book.modules.coderunner.repository.RScriptRepository;
import com.csu.r_book.modules.coderunner.repository.ScriptVariableRepository;
import com.csu.r_book.modules.coderunner.service.CodeRunnerService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.Semaphore;
import java.util.stream.Collectors;

/**
 * Code Runner 服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CodeRunnerServiceImpl implements CodeRunnerService {

    private final RScriptRepository scriptRepository;
    private final ScriptVariableRepository variableRepository;
    private final ExecutionLogRepository logRepository;
    private final ChapterRepository chapterRepository;
    private final RScriptExecutor rScriptExecutor;
    private final ObjectMapper objectMapper;
    private final CodeRunnerProperties properties;

    /**
     * 限制同时运行的 R 进程数量，防止服务器资源耗尽
     */
    private final Semaphore executionSemaphore = new Semaphore(
            Runtime.getRuntime().availableProcessors()
    );

    @Override
    public List<ScriptDefinitionDTO> getAllScripts() {
        List<RScriptEntity> scripts = scriptRepository.findAll();
        return scripts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public ScriptDefinitionDTO getScriptById(String id) {
        Optional<RScriptEntity> scriptOpt = scriptRepository.findById(id);
        return scriptOpt.map(this::convertToDTO).orElse(null);
    }

    @Override
    public ExecutionResultDTO executeScript(ExecuteRequestDTO request) {
        String scriptId = request.getScriptId();
        log.info("Executing script: {}", scriptId);

        // 1. 查找脚本
        Optional<RScriptEntity> scriptOpt = scriptRepository.findById(scriptId);
        if (scriptOpt.isEmpty()) {
            log.warn("Script not found: {}", scriptId);
            return ExecutionResultDTO.builder()
                    .success(false)
                    .error("Script not found: " + scriptId)
                    .build();
        }

        RScriptEntity script = scriptOpt.get();

        // 2. 合并变量：先用默认值填充，再用请求中的值覆盖
        Map<String, Object> mergedVariables = mergeVariablesWithDefaults(script, request.getVariables());

        // 3. 确定使用的 CSV 数据：优先使用用户上传的数据，否则使用数据库中的示例数据
        String csvData = request.getFileData();
        if (!StringUtils.hasText(csvData) && StringUtils.hasText(script.getExampleData())) {
            log.info("No user data provided, using example data from database for script: {}", scriptId);
            csvData = script.getExampleData();
        }

        ExecutionResultDTO result;

        // 4. 使用信号量限制并发
        try {
            executionSemaphore.acquire();
            log.debug("Acquired execution permit, remaining: {}", executionSemaphore.availablePermits());

            // 5. 调用 RScriptExecutor 执行脚本
            result = rScriptExecutor.run(
                    script.getFilePath(),
                    mergedVariables,
                    csvData
            );

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Execution interrupted", e);
            result = ExecutionResultDTO.builder()
                    .success(false)
                    .error("Execution interrupted")
                    .build();
        } finally {
            executionSemaphore.release();
            log.debug("Released execution permit");
        }

        // 5. 记录执行日志
        saveExecutionLog(request, result);

        return result;
    }

    /**
     * 将 Entity 转换为 DTO
     */
    private ScriptDefinitionDTO convertToDTO(RScriptEntity entity) {
        List<ScriptDefinitionDTO.VariableDefinition> variables = Collections.emptyList();

        if (entity.getVariables() != null && !entity.getVariables().isEmpty()) {
            variables = entity.getVariables().stream()
                    .map(this::convertVariableToDTO)
                    .collect(Collectors.toList());
        }

        // 读取脚本文件内容
        String scriptContent = readScriptFile(entity.getFilePath());

        return ScriptDefinitionDTO.builder()
                .id(entity.getId())
                .name(entity.getName())
                .description(entity.getDescription())
                .supportsVariables(entity.getSupportsVariables())
                .supportsFileInput(entity.getSupportsFileInput())
                .fileInputDesc(entity.getFileInputDesc())
                .exampleData(entity.getExampleData())
                .chapter(entity.getChapter())
                .sortOrder(entity.getSortOrder())
                .scriptContent(scriptContent)
                .variables(variables)
                .build();
    }

    /**
     * 将变量 Entity 转换为 DTO
     */
    private ScriptDefinitionDTO.VariableDefinition convertVariableToDTO(ScriptVariableEntity entity) {
        return ScriptDefinitionDTO.VariableDefinition.builder()
                .name(entity.getName())
                .label(entity.getLabel())
                .type(entity.getType().name())
                .defaultValue(entity.getDefaultValue())
                .description(entity.getDescription())
                .build();
    }

    /**
     * 合并变量：用默认值填充缺失的变量
     *
     * @param script           脚本实体（包含变量定义和默认值）
     * @param requestVariables 请求中传入的变量
     * @return 合并后的变量 Map
     */
    private Map<String, Object> mergeVariablesWithDefaults(RScriptEntity script, Map<String, Object> requestVariables) {
        Map<String, Object> merged = new HashMap<>();

        // 如果脚本有变量定义，先用默认值填充
        if (script.getVariables() != null && !script.getVariables().isEmpty()) {
            for (ScriptVariableEntity varDef : script.getVariables()) {
                String varName = varDef.getName();
                String defaultValue = varDef.getDefaultValue();

                if (defaultValue != null && !defaultValue.isEmpty()) {
                    // 根据类型转换默认值
                    Object typedValue = convertDefaultValue(defaultValue, varDef.getType());
                    merged.put(varName, typedValue);
                    log.debug("Using default value for {}: {}", varName, typedValue);
                }
            }
        }

        // 用请求中的值覆盖默认值
        if (requestVariables != null && !requestVariables.isEmpty()) {
            merged.putAll(requestVariables);
            log.debug("Merged request variables: {}", requestVariables.keySet());
        }

        return merged;
    }

    /**
     * 根据类型转换默认值字符串
     */
    private Object convertDefaultValue(String value, ScriptVariableEntity.VariableType type) {
        if (value == null || value.isEmpty()) {
            return null;
        }

        try {
            switch (type) {
                case NUMBER:
                    // 尝试解析为数字
                    if (value.contains(".")) {
                        return Double.parseDouble(value);
                    } else {
                        return Long.parseLong(value);
                    }
                case BOOLEAN:
                    return Boolean.parseBoolean(value);
                case STRING:
                default:
                    return value;
            }
        } catch (NumberFormatException e) {
            log.warn("Failed to convert default value '{}' to type {}, using as string", value, type);
            return value;
        }
    }

    /**
     * 保存执行日志
     */
    private void saveExecutionLog(ExecuteRequestDTO request, ExecutionResultDTO result) {
        try {
            ExecutionLogEntity logEntity = new ExecutionLogEntity();
            logEntity.setScriptId(request.getScriptId());
            logEntity.setIsSuccess(result.getSuccess());
            logEntity.setExecutionTimeMs(result.getExecutionTime());
            logEntity.setErrorMessage(result.getError());

            // 序列化请求参数
            try {
                logEntity.setRequestParams(objectMapper.writeValueAsString(request));
            } catch (JsonProcessingException e) {
                log.warn("Failed to serialize request params", e);
            }

            logRepository.save(logEntity);
            log.debug("Saved execution log for script: {}", request.getScriptId());
        } catch (Exception e) {
            log.error("Failed to save execution log", e);
        }
    }

    @Override
    @Transactional
    public ScriptDefinitionDTO createScript(ScriptCreateDTO createDTO) {
        validateChapterExists(createDTO.getChapter());
        // 1. 生成唯一ID
        String scriptId = generateScriptId();
        log.info("Creating script with generated id: {}", scriptId);

        // 2. 保存 R 脚本文件
        String fileName = scriptId + ".R";
        saveScriptFile(fileName, createDTO.getScriptContent());

        // 3. 创建脚本实体
        RScriptEntity entity = new RScriptEntity();
        entity.setId(scriptId);
        entity.setName(createDTO.getName());
        entity.setDescription(createDTO.getDescription());
        entity.setFilePath(fileName);
        entity.setSupportsVariables(createDTO.getSupportsVariables() != null ? createDTO.getSupportsVariables() : false);
        entity.setSupportsFileInput(createDTO.getSupportsFileInput() != null ? createDTO.getSupportsFileInput() : false);
        entity.setFileInputDesc(createDTO.getFileInputDesc());
        entity.setExampleData(createDTO.getExampleData());
        entity.setChapter(createDTO.getChapter());
        entity.setSortOrder(createDTO.getSortOrder());

        // 4. 保存脚本
        scriptRepository.save(entity);

        // 5. 保存变量配置
        if (createDTO.getVariables() != null && !createDTO.getVariables().isEmpty()) {
            List<ScriptVariableEntity> variables = new ArrayList<>();
            for (int i = 0; i < createDTO.getVariables().size(); i++) {
                ScriptCreateDTO.VariableCreateDTO varDTO = createDTO.getVariables().get(i);
                ScriptVariableEntity varEntity = new ScriptVariableEntity();
                varEntity.setScript(entity);
                varEntity.setName(varDTO.getName());
                varEntity.setLabel(varDTO.getLabel());
                varEntity.setType(ScriptVariableEntity.VariableType.valueOf(varDTO.getType()));
                varEntity.setDefaultValue(varDTO.getDefaultValue());
                varEntity.setDescription(varDTO.getDescription());
                varEntity.setSortOrder(varDTO.getSortOrder() != null ? varDTO.getSortOrder() : i);
                variables.add(varEntity);
            }
            variableRepository.saveAll(variables);
            entity.setVariables(variables);
        }

        log.info("Script created successfully: {}", scriptId);
        return convertToDTO(entity);
    }

    @Override
    @Transactional
    public ScriptDefinitionDTO updateScript(String id, ScriptUpdateDTO updateDTO) {
        log.info("Updating script: {}", id);

        // 1. 查找脚本
        RScriptEntity entity = scriptRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("脚本不存在: " + id));

        // 2. 更新脚本文件（如果有提供）
        if (StringUtils.hasText(updateDTO.getScriptContent())) {
            saveScriptFile(entity.getFilePath(), updateDTO.getScriptContent());
        }

        // 3. 更新脚本信息
        entity.setName(updateDTO.getName());
        if (updateDTO.getDescription() != null) {
            entity.setDescription(updateDTO.getDescription());
        }
        if (updateDTO.getSupportsVariables() != null) {
            entity.setSupportsVariables(updateDTO.getSupportsVariables());
        }
        if (updateDTO.getSupportsFileInput() != null) {
            entity.setSupportsFileInput(updateDTO.getSupportsFileInput());
        }
        if (updateDTO.getFileInputDesc() != null) {
            entity.setFileInputDesc(updateDTO.getFileInputDesc());
        }
        if (updateDTO.getExampleData() != null) {
            entity.setExampleData(updateDTO.getExampleData());
        }
        if (updateDTO.getChapter() != null) {
            validateChapterExists(updateDTO.getChapter());
            entity.setChapter(updateDTO.getChapter());
        }
        if (updateDTO.getSortOrder() != null) {
            entity.setSortOrder(updateDTO.getSortOrder());
        }

        // 4. 更新变量配置（如果有提供，则全量替换）
        if (updateDTO.getVariables() != null) {
            // 删除旧变量
            variableRepository.deleteAll(variableRepository.findByScriptIdOrderBySortOrderAsc(id));

            // 添加新变量
            if (!updateDTO.getVariables().isEmpty()) {
                List<ScriptVariableEntity> variables = new ArrayList<>();
                for (int i = 0; i < updateDTO.getVariables().size(); i++) {
                    ScriptUpdateDTO.VariableUpdateDTO varDTO = updateDTO.getVariables().get(i);
                    ScriptVariableEntity varEntity = new ScriptVariableEntity();
                    varEntity.setScript(entity);
                    varEntity.setName(varDTO.getName());
                    varEntity.setLabel(varDTO.getLabel());
                    varEntity.setType(ScriptVariableEntity.VariableType.valueOf(varDTO.getType()));
                    varEntity.setDefaultValue(varDTO.getDefaultValue());
                    varEntity.setDescription(varDTO.getDescription());
                    varEntity.setSortOrder(varDTO.getSortOrder() != null ? varDTO.getSortOrder() : i);
                    variables.add(varEntity);
                }
                variableRepository.saveAll(variables);
                entity.setVariables(variables);
            } else {
                entity.setVariables(Collections.emptyList());
            }
        }

        // 5. 保存更新
        scriptRepository.save(entity);

        log.info("Script updated successfully: {}", id);
        return convertToDTO(entity);
    }

    @Override
    @Transactional
    public boolean deleteScript(String id) {
        log.info("Deleting script: {}", id);

        Optional<RScriptEntity> scriptOpt = scriptRepository.findById(id);
        if (scriptOpt.isEmpty()) {
            return false;
        }

        RScriptEntity entity = scriptOpt.get();
        
        // 逻辑删除
        entity.setIsDeleted(1);
        scriptRepository.save(entity);

        log.info("Script deleted (logical) successfully: {}", id);
        return true;
    }

    /**
     * 保存 R 脚本文件到存储目录
     */
    private void saveScriptFile(String fileName, String content) {
        try {
            Path scriptDir = Paths.get(properties.getScriptStoragePath());
            
            // 确保目录存在
            if (!Files.exists(scriptDir)) {
                Files.createDirectories(scriptDir);
            }

            Path filePath = scriptDir.resolve(fileName);
            Files.writeString(filePath, content);
            log.info("Script file saved: {}", filePath);
        } catch (IOException e) {
            log.error("Failed to save script file: {}", fileName, e);
            throw new RuntimeException("保存脚本文件失败: " + e.getMessage(), e);
        }
    }

    /**
     * 读取 R 脚本文件内容
     */
    private String readScriptFile(String fileName) {
        try {
            Path filePath = Paths.get(properties.getScriptStoragePath(), fileName);
            if (Files.exists(filePath)) {
                return Files.readString(filePath);
            } else {
                log.warn("Script file not found: {}", filePath);
                return null;
            }
        } catch (IOException e) {
            log.error("Failed to read script file: {}", fileName, e);
            return null;
        }
    }

    /**
     * 生成脚本ID
     * 使用时间戳 + 随机字符的方式生成短且唯一的ID
     */
    private String generateScriptId() {
        // 使用当前时间戳（秒级）转36进制 + 4位随机字符
        long timestamp = System.currentTimeMillis() / 1000;
        String timePart = Long.toString(timestamp, 36);
        String randomPart = Long.toString((long) (Math.random() * 1679616), 36); // 36^4 = 1679616
        
        // 补齐随机部分到4位
        while (randomPart.length() < 4) {
            randomPart = "0" + randomPart;
        }
        
        return "script-" + timePart + randomPart;
    }
    
    @Override
    public List<ScriptDefinitionDTO> getScriptsByChapter(String chapter) {
        List<RScriptEntity> scripts;
        if (chapter == null || chapter.isEmpty()) {
            scripts = scriptRepository.findAll();
        } else {
            scripts = scriptRepository.findByChapterOrderBySortOrderAsc(chapter);
        }
        return scripts.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    @Override
    public List<ChapterDTO> getAllChapters() {
        List<ChapterEntity> chapters = chapterRepository.findByIsDeletedOrderBySortOrderAscIdAsc(0);
        return chapters.stream()
                .map(this::toChapterDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<ChapterAdminDTO> getAllChaptersForAdmin() {
        List<ChapterEntity> chapters = chapterRepository.findByIsDeletedOrderBySortOrderAscIdAsc(0);
        return chapters.stream()
                .map(this::toChapterAdminDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ChapterAdminDTO createChapter(ChapterCreateDTO createDTO) {
        String name = createDTO.getName();
        if (!StringUtils.hasText(name)) {
            throw new IllegalArgumentException("章节名称不能为空");
        }

        Optional<ChapterEntity> existing = chapterRepository.findByName(name);
        if (existing.isPresent()) {
            ChapterEntity existingEntity = existing.get();
            if (existingEntity.getIsDeleted() != null && existingEntity.getIsDeleted() == 1) {
                existingEntity.setIsDeleted(0);
                if (createDTO.getSortOrder() != null) {
                    existingEntity.setSortOrder(createDTO.getSortOrder());
                }
                ChapterEntity saved = chapterRepository.save(existingEntity);
                return toChapterAdminDTO(saved);
            }
            throw new IllegalArgumentException("章节已存在: " + name);
        }

        ChapterEntity entity = new ChapterEntity();
        entity.setName(name);
        entity.setSortOrder(createDTO.getSortOrder() != null ? createDTO.getSortOrder() : 0);
        ChapterEntity saved = chapterRepository.save(entity);
        return toChapterAdminDTO(saved);
    }

    @Override
    @Transactional
    public ChapterAdminDTO updateChapter(Long id, ChapterUpdateDTO updateDTO) {
        ChapterEntity entity = chapterRepository.findByIdAndIsDeleted(id, 0)
                .orElseThrow(() -> new IllegalArgumentException("章节不存在: " + id));

        if (updateDTO.getName() != null) {
            String newName = updateDTO.getName();
            if (!StringUtils.hasText(newName)) {
                throw new IllegalArgumentException("章节名称不能为空");
            }
            Optional<ChapterEntity> existing = chapterRepository.findByName(newName);
            if (existing.isPresent() && !existing.get().getId().equals(entity.getId())) {
                throw new IllegalArgumentException("章节名称已存在: " + newName);
            }
            entity.setName(newName);
        }
        if (updateDTO.getSortOrder() != null) {
            entity.setSortOrder(updateDTO.getSortOrder());
        }

        ChapterEntity saved = chapterRepository.save(entity);
        return toChapterAdminDTO(saved);
    }

    @Override
    @Transactional
    public boolean deleteChapter(Long id) {
        Optional<ChapterEntity> chapterOpt = chapterRepository.findByIdAndIsDeleted(id, 0);
        if (chapterOpt.isEmpty()) {
            return false;
        }

        ChapterEntity entity = chapterOpt.get();
        entity.setIsDeleted(1);
        chapterRepository.save(entity);
        return true;
    }

    private ChapterDTO toChapterDTO(ChapterEntity entity) {
        return ChapterDTO.builder()
                .name(entity.getName())
                .scriptCount(scriptRepository.countByChapter(entity.getName()))
                .sortOrder(entity.getSortOrder())
                .build();
    }

    private ChapterAdminDTO toChapterAdminDTO(ChapterEntity entity) {
        return ChapterAdminDTO.builder()
                .id(entity.getId())
                .name(entity.getName())
                .sortOrder(entity.getSortOrder())
                .scriptCount(scriptRepository.countByChapter(entity.getName()))
                .build();
    }

    private void validateChapterExists(String chapter) {
        if (!StringUtils.hasText(chapter)) {
            return;
        }
        if (chapterRepository.findByNameAndIsDeleted(chapter, 0).isEmpty()) {
            throw new IllegalArgumentException("章节不存在: " + chapter);
        }
    }
}
