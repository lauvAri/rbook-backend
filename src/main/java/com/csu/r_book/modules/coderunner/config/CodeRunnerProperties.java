package com.csu.r_book.modules.coderunner.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Code Runner 配置属性
 */
@Data
@Component
@ConfigurationProperties(prefix = "app.coderunner")
public class CodeRunnerProperties {

    /**
     * Rscript 可执行文件路径
     */
    private String rExecutable = "Rscript";

    /**
     * R 脚本存储路径
     */
    private String scriptStoragePath = "/var/data/r-scripts";

    /**
     * 执行超时时间 (秒)
     */
    private Integer timeoutSeconds = 30;

    /**
     * 最大文件大小
     */
    private String maxFileSize = "5MB";
}
