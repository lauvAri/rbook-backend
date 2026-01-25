package com.csu.r_book.modules.captcha.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 验证码响应 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CaptchaDTO {
    
    /**
     * 验证码唯一标识，登录时需回传
     */
    private String captchaKey;
    
    /**
     * Base64 编码的验证码图片（含 data URI 前缀）
     */
    private String captchaImage;
}
