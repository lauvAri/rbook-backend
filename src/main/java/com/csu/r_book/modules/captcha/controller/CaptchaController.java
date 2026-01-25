package com.csu.r_book.modules.captcha.controller;

import com.csu.r_book.common.Result;
import com.csu.r_book.modules.captcha.model.dto.CaptchaDTO;
import com.csu.r_book.modules.captcha.service.CaptchaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 验证码控制器
 */
@RestController
@RequestMapping("/api/captcha")
public class CaptchaController {
    
    @Autowired
    private CaptchaService captchaService;
    
    /**
     * 获取图片验证码
     */
    @GetMapping
    public Result<CaptchaDTO> getCaptcha() {
        CaptchaDTO captcha = captchaService.generateCaptcha();
        return Result.success(captcha);
    }
}
