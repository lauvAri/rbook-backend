package com.csu.r_book.modules.captcha.service;

import com.csu.r_book.modules.captcha.model.dto.CaptchaDTO;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 验证码服务
 */
@Service
public class CaptchaService {
    
    /**
     * 验证码缓存：key -> (code, expireTime)
     */
    private final Map<String, CaptchaEntry> captchaCache = new ConcurrentHashMap<>();
    
    /**
     * 验证码有效期（毫秒）
     */
    private static final long CAPTCHA_EXPIRE_MS = 5 * 60 * 1000; // 5分钟
    
    /**
     * 验证码字符集
     */
    private static final String CAPTCHA_CHARS = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    
    /**
     * 验证码长度
     */
    private static final int CAPTCHA_LENGTH = 4;
    
    /**
     * 图片宽度
     */
    private static final int IMAGE_WIDTH = 120;
    
    /**
     * 图片高度
     */
    private static final int IMAGE_HEIGHT = 40;
    
    private final SecureRandom random = new SecureRandom();
    
    public CaptchaService() {
        // 启动定时清理过期验证码的任务
        ScheduledExecutorService scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(this::cleanExpiredCaptcha, 1, 1, TimeUnit.MINUTES);
    }
    
    /**
     * 生成验证码
     */
    public CaptchaDTO generateCaptcha() {
        // 生成验证码文本
        String code = generateRandomCode();
        
        // 生成唯一标识
        String captchaKey = UUID.randomUUID().toString();
        
        // 存储到缓存
        captchaCache.put(captchaKey, new CaptchaEntry(code.toLowerCase(), System.currentTimeMillis() + CAPTCHA_EXPIRE_MS));
        
        // 生成图片
        String base64Image = generateCaptchaImage(code);
        
        return CaptchaDTO.builder()
                .captchaKey(captchaKey)
                .captchaImage("data:image/png;base64," + base64Image)
                .build();
    }
    
    /**
     * 验证验证码
     * @param captchaKey 验证码标识
     * @param captchaCode 用户输入的验证码
     * @return 是否验证通过
     */
    public boolean verifyCaptcha(String captchaKey, String captchaCode) {
        if (captchaKey == null || captchaCode == null) {
            return false;
        }
        
        CaptchaEntry entry = captchaCache.remove(captchaKey); // 验证后立即移除（一次性使用）
        
        if (entry == null) {
            return false;
        }
        
        if (System.currentTimeMillis() > entry.expireTime) {
            return false;
        }
        
        return entry.code.equalsIgnoreCase(captchaCode.trim());
    }
    
    /**
     * 生成随机验证码文本
     */
    private String generateRandomCode() {
        StringBuilder sb = new StringBuilder(CAPTCHA_LENGTH);
        for (int i = 0; i < CAPTCHA_LENGTH; i++) {
            sb.append(CAPTCHA_CHARS.charAt(random.nextInt(CAPTCHA_CHARS.length())));
        }
        return sb.toString();
    }
    
    /**
     * 生成验证码图片
     */
    private String generateCaptchaImage(String code) {
        BufferedImage image = new BufferedImage(IMAGE_WIDTH, IMAGE_HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        
        // 设置抗锯齿
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        // 填充背景
        g.setColor(new Color(240, 240, 240));
        g.fillRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        
        // 绘制干扰线
        for (int i = 0; i < 6; i++) {
            g.setColor(new Color(random.nextInt(200), random.nextInt(200), random.nextInt(200)));
            int x1 = random.nextInt(IMAGE_WIDTH);
            int y1 = random.nextInt(IMAGE_HEIGHT);
            int x2 = random.nextInt(IMAGE_WIDTH);
            int y2 = random.nextInt(IMAGE_HEIGHT);
            g.drawLine(x1, y1, x2, y2);
        }
        
        // 绘制干扰点
        for (int i = 0; i < 30; i++) {
            g.setColor(new Color(random.nextInt(200), random.nextInt(200), random.nextInt(200)));
            int x = random.nextInt(IMAGE_WIDTH);
            int y = random.nextInt(IMAGE_HEIGHT);
            g.fillOval(x, y, 2, 2);
        }
        
        // 绘制验证码字符
        g.setFont(new Font("Arial", Font.BOLD, 28));
        for (int i = 0; i < code.length(); i++) {
            g.setColor(new Color(random.nextInt(100), random.nextInt(100), random.nextInt(100)));
            // 添加轻微旋转
            double angle = (random.nextDouble() - 0.5) * 0.3;
            g.rotate(angle, 25 + i * 25, 25);
            g.drawString(String.valueOf(code.charAt(i)), 15 + i * 25, 30);
            g.rotate(-angle, 25 + i * 25, 25);
        }
        
        g.dispose();
        
        // 转换为 Base64
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            ImageIO.write(image, "PNG", baos);
            return Base64.getEncoder().encodeToString(baos.toByteArray());
        } catch (Exception e) {
            throw new RuntimeException("生成验证码图片失败", e);
        }
    }
    
    /**
     * 清理过期验证码
     */
    private void cleanExpiredCaptcha() {
        long now = System.currentTimeMillis();
        captchaCache.entrySet().removeIf(entry -> entry.getValue().expireTime < now);
    }
    
    /**
     * 验证码缓存条目
     */
    private record CaptchaEntry(String code, long expireTime) {}
}
