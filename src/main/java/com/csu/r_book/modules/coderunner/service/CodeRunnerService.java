package com.csu.r_book.modules.coderunner.service;

import com.csu.r_book.modules.coderunner.model.dto.*;

import java.util.List;

/**
 * Code Runner 服务接口
 */
public interface CodeRunnerService {

    /**
     * 获取所有可用脚本列表
     *
     * @return 脚本定义列表
     */
    List<ScriptDefinitionDTO> getAllScripts();

    /**
     * 根据ID获取脚本详情
     *
     * @param id 脚本ID
     * @return 脚本定义，不存在则返回 null
     */
    ScriptDefinitionDTO getScriptById(String id);

    /**
     * 执行脚本
     *
     * @param request 执行请求
     * @return 执行结果
     */
    ExecutionResultDTO executeScript(ExecuteRequestDTO request);

    /**
     * 创建新脚本
     *
     * @param createDTO 创建请求
     * @return 创建后的脚本定义
     */
    ScriptDefinitionDTO createScript(ScriptCreateDTO createDTO);

    /**
     * 更新脚本
     *
     * @param id        脚本ID
     * @param updateDTO 更新请求
     * @return 更新后的脚本定义
     */
    ScriptDefinitionDTO updateScript(String id, ScriptUpdateDTO updateDTO);

    /**
     * 删除脚本（逻辑删除）
     *
     * @param id 脚本ID
     * @return 是否删除成功
     */
    boolean deleteScript(String id);
    
    /**
     * 根据章节获取脚本列表
     *
     * @param chapter 章节名称，为空则返回全部
     * @return 脚本定义列表
     */
    List<ScriptDefinitionDTO> getScriptsByChapter(String chapter);
    
    /**
     * 获取章节列表
     *
     * @return 章节列表（含脚本数量）
     */
    List<ChapterDTO> getAllChapters();
}
