package com.csu.r_book.modules.coderunner.controller;

import com.csu.r_book.common.Result;
import com.csu.r_book.config.AuthInterceptor;
import com.csu.r_book.modules.coderunner.model.dto.ScriptCreateDTO;
import com.csu.r_book.modules.coderunner.model.dto.ScriptDefinitionDTO;
import com.csu.r_book.modules.coderunner.model.dto.ScriptUpdateDTO;
import com.csu.r_book.modules.coderunner.service.CodeRunnerService;
import com.csu.r_book.modules.user.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 脚本管理 API 控制器
 * 用于创建、更新、删除脚本/题目
 */
@Slf4j
@RestController
@RequestMapping("/api/code-runner/admin")
@RequiredArgsConstructor
public class ScriptAdminController {

    private final CodeRunnerService codeRunnerService;
    private final UserService userService;

    /**
     * 创建新脚本
     * POST /api/code-runner/admin/scripts
     */
    @PostMapping("/scripts")
    public Result<ScriptDefinitionDTO> createScript(
            @Valid @RequestBody ScriptCreateDTO createDTO,
            HttpServletRequest request) {
        log.info("Creating script: {}", createDTO.getName());
        try {
            ScriptDefinitionDTO result = codeRunnerService.createScript(createDTO);
            
            // 记录操作日志
            Long userId = getCurrentUserId(request);
            if (userId != null) {
                userService.logOperation(userId, "CREATE_SCRIPT", result.getId());
            }
            
            return Result.success(result);
        } catch (IllegalArgumentException e) {
            return Result.error(1001, e.getMessage());
        } catch (Exception e) {
            log.error("Failed to create script", e);
            return Result.error(5000, "创建脚本失败: " + e.getMessage());
        }
    }

    /**
     * 更新脚本
     * PUT /api/code-runner/admin/scripts/{id}
     */
    @PutMapping("/scripts/{id}")
    public Result<ScriptDefinitionDTO> updateScript(
            @PathVariable String id,
            @Valid @RequestBody ScriptUpdateDTO updateDTO,
            HttpServletRequest request) {
        log.info("Updating script: {}", id);
        try {
            ScriptDefinitionDTO result = codeRunnerService.updateScript(id, updateDTO);
            
            // 记录操作日志
            Long userId = getCurrentUserId(request);
            if (userId != null) {
                userService.logOperation(userId, "UPDATE_SCRIPT", id);
            }
            
            return Result.success(result);
        } catch (IllegalArgumentException e) {
            return Result.error(1002, e.getMessage());
        } catch (Exception e) {
            log.error("Failed to update script", e);
            return Result.error(5000, "更新脚本失败: " + e.getMessage());
        }
    }

    /**
     * 删除脚本（逻辑删除）
     * DELETE /api/code-runner/admin/scripts/{id}
     */
    @DeleteMapping("/scripts/{id}")
    public Result<Void> deleteScript(@PathVariable String id, HttpServletRequest request) {
        log.info("Deleting script: {}", id);
        try {
            boolean success = codeRunnerService.deleteScript(id);
            if (success) {
                // 记录操作日志
                Long userId = getCurrentUserId(request);
                if (userId != null) {
                    userService.logOperation(userId, "DELETE_SCRIPT", id);
                }
                
                return Result.success();
            } else {
                return Result.error(1002, "脚本不存在");
            }
        } catch (Exception e) {
            log.error("Failed to delete script", e);
            return Result.error(5000, "删除脚本失败: " + e.getMessage());
        }
    }
    
    /**
     * 从请求中获取当前登录用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        return AuthInterceptor.getUserId(token);
    }
}
