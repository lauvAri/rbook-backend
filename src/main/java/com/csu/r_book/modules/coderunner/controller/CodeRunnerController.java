package com.csu.r_book.modules.coderunner.controller;

import com.csu.r_book.common.Result;
import com.csu.r_book.modules.coderunner.model.dto.ChapterDTO;
import com.csu.r_book.modules.coderunner.model.dto.ExecuteRequestDTO;
import com.csu.r_book.modules.coderunner.model.dto.ExecutionResultDTO;
import com.csu.r_book.modules.coderunner.model.dto.ScriptDefinitionDTO;
import com.csu.r_book.modules.coderunner.service.CodeRunnerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Code Runner API 控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/code-runner")
@RequiredArgsConstructor
public class CodeRunnerController {

    private final CodeRunnerService codeRunnerService;

    /**
     * 获取脚本列表（支持章节筛选）
     * GET /api/code-runner/scripts?chapter={chapterName}
     */
    @GetMapping("/scripts")
    public Result<List<ScriptDefinitionDTO>> listScripts(
            @RequestParam(required = false) String chapter) {
        log.info("Fetching scripts, chapter filter: {}", chapter);
        List<ScriptDefinitionDTO> scripts = codeRunnerService.getScriptsByChapter(chapter);
        return Result.success(scripts);
    }
    
    /**
     * 获取章节列表
     * GET /api/code-runner/chapters
     */
    @GetMapping("/chapters")
    public Result<List<ChapterDTO>> listChapters() {
        log.info("Fetching all chapters");
        List<ChapterDTO> chapters = codeRunnerService.getAllChapters();
        return Result.success(chapters);
    }

    /**
     * 获取脚本详情
     * GET /api/code-runner/scripts/{id}
     */
    @GetMapping("/scripts/{id}")
    public Result<ScriptDefinitionDTO> getScript(@PathVariable String id) {
        log.info("Fetching script by id: {}", id);
        ScriptDefinitionDTO script = codeRunnerService.getScriptById(id);
        if (script == null) {
            return Result.error(1002, "脚本不存在");
        }
        return Result.success(script);
    }

    /**
     * 执行脚本
     * POST /api/code-runner/execute
     */
    @PostMapping("/execute")
    public Result<ExecutionResultDTO> execute(@RequestBody ExecuteRequestDTO request) {
        log.info("Executing script: {}", request.getScriptId());

        // 参数校验
        if (!StringUtils.hasText(request.getScriptId())) {
            return Result.error(1001, "scriptId 不能为空");
        }

        try {
            ExecutionResultDTO result = codeRunnerService.executeScript(request);
            return Result.success(result);
        } catch (Exception e) {
            log.error("执行过程发生系统错误", e);
            return Result.error(5000, "执行过程发生系统错误: " + e.getMessage());
        }
    }
}
