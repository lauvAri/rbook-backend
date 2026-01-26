package com.csu.r_book.modules.coderunner.controller;

import com.csu.r_book.common.Result;
import com.csu.r_book.config.AuthInterceptor;
import com.csu.r_book.modules.coderunner.model.dto.ChapterAdminDTO;
import com.csu.r_book.modules.coderunner.model.dto.ChapterCreateDTO;
import com.csu.r_book.modules.coderunner.model.dto.ChapterUpdateDTO;
import com.csu.r_book.modules.coderunner.service.CodeRunnerService;
import com.csu.r_book.modules.user.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 章节管理 API 控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/code-runner/admin/chapters")
@RequiredArgsConstructor
public class ChapterAdminController {

    private final CodeRunnerService codeRunnerService;
    private final UserService userService;

    /**
     * 获取章节列表（管理端）
     * GET /api/code-runner/admin/chapters
     */
    @GetMapping
    public Result<List<ChapterAdminDTO>> listChapters() {
        log.info("Fetching admin chapters");
        return Result.success(codeRunnerService.getAllChaptersForAdmin());
    }

    /**
     * 创建章节
     * POST /api/code-runner/admin/chapters
     */
    @PostMapping
    public Result<ChapterAdminDTO> createChapter(
            @Valid @RequestBody ChapterCreateDTO createDTO,
            HttpServletRequest request) {
        log.info("Creating chapter: {}", createDTO.getName());
        try {
            ChapterAdminDTO result = codeRunnerService.createChapter(createDTO);
            logOperation(request, "CREATE_CHAPTER", result.getName());
            return Result.success(result);
        } catch (IllegalArgumentException e) {
            return Result.error(1001, e.getMessage());
        } catch (Exception e) {
            log.error("Failed to create chapter", e);
            return Result.error(5000, "创建章节失败: " + e.getMessage());
        }
    }

    /**
     * 更新章节
     * PUT /api/code-runner/admin/chapters/{id}
     */
    @PutMapping("/{id}")
    public Result<ChapterAdminDTO> updateChapter(
            @PathVariable Long id,
            @Valid @RequestBody ChapterUpdateDTO updateDTO,
            HttpServletRequest request) {
        log.info("Updating chapter: {}", id);
        try {
            ChapterAdminDTO result = codeRunnerService.updateChapter(id, updateDTO);
            logOperation(request, "UPDATE_CHAPTER", result.getName());
            return Result.success(result);
        } catch (IllegalArgumentException e) {
            return Result.error(1002, e.getMessage());
        } catch (Exception e) {
            log.error("Failed to update chapter", e);
            return Result.error(5000, "更新章节失败: " + e.getMessage());
        }
    }

    /**
     * 删除章节（逻辑删除）
     * DELETE /api/code-runner/admin/chapters/{id}
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteChapter(@PathVariable Long id, HttpServletRequest request) {
        log.info("Deleting chapter: {}", id);
        try {
            boolean success = codeRunnerService.deleteChapter(id);
            if (success) {
                logOperation(request, "DELETE_CHAPTER", String.valueOf(id));
                return Result.success();
            }
            return Result.error(1002, "章节不存在");
        } catch (Exception e) {
            log.error("Failed to delete chapter", e);
            return Result.error(5000, "删除章节失败: " + e.getMessage());
        }
    }

    private void logOperation(HttpServletRequest request, String operationType, String target) {
        Long userId = getCurrentUserId(request);
        if (userId != null) {
            userService.logOperation(userId, operationType, target);
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
