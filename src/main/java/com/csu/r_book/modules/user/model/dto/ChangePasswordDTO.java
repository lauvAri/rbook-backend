package com.csu.r_book.modules.user.model.dto;

import lombok.Data;

/**
 * 修改密码请求 DTO
 */
@Data
public class ChangePasswordDTO {
    private String oldPassword;
    private String newPassword;
}