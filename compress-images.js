const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const inputDir = path.join(__dirname, 'src', 'static', 'tabbar');
const outputDir = path.join(__dirname, 'src', 'static', 'tabbar');

// 确保输出目录存在
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
}

// 获取所有PNG文件
const files = fs.readdirSync(inputDir).filter(file => file.endsWith('.png'));

console.log('开始压缩图片...');
console.log(`找到 ${files.length} 个PNG文件\n`);

async function compressImage(inputPath, outputPath, targetSizeKB = 20) {
    try {
        const inputBuffer = fs.readFileSync(inputPath);
        const inputSizeKB = inputBuffer.length / 1024;

        console.log(`处理: ${path.basename(inputPath)}`);
        console.log(`  原始大小: ${inputSizeKB.toFixed(2)} KB`);

        // 如果已经小于目标大小，直接复制
        if (inputSizeKB <= targetSizeKB) {
            fs.copyFileSync(inputPath, outputPath);
            console.log(`  无需压缩，直接复制`);
            return;
        }

        // 使用sharp压缩
        const compressed = await sharp(inputBuffer)
            .resize(81, 81, { fit: 'inside', withoutEnlargement: true })
            .png({ quality: 80, compressionLevel: 9 })
            .toBuffer();

        const compressedSizeKB = compressed.length / 1024;
        console.log(`  压缩后: ${compressedSizeKB.toFixed(2)} KB`);

        // 如果还是太大，降低质量重试
        let quality = 80;
        let resultBuffer = compressed;
        let resultSizeKB = compressedSizeKB;

        while (resultSizeKB > targetSizeKB && quality > 20) {
            quality -= 10;
            resultBuffer = await sharp(inputBuffer)
                .resize(81, 81, { fit: 'inside', withoutEnlargement: true })
                .png({ quality: quality, compressionLevel: 9 })
                .toBuffer();
            resultSizeKB = resultBuffer.length / 1024;
        }

        if (resultSizeKB > targetSizeKB) {
            // 最后尝试：降低尺寸
            resultBuffer = await sharp(inputBuffer)
                .resize(48, 48, { fit: 'inside', withoutEnlargement: true })
                .png({ quality: 60, compressionLevel: 9 })
                .toBuffer();
            resultSizeKB = resultBuffer.length / 1024;
        }

        console.log(`  最终大小: ${resultSizeKB.toFixed(2)} KB`);
        fs.writeFileSync(outputPath, resultBuffer);
        console.log(`  ✓ 保存成功\n`);

    } catch (error) {
        console.error(`  ✗ 压缩失败: ${error.message}\n`);
    }
}

async function main() {
    for (const file of files) {
        const inputPath = path.join(inputDir, file);
        const outputPath = path.join(outputDir, file);
        await compressImage(inputPath, outputPath, 20);
    }

    console.log('所有图片压缩完成！');
}

main().catch(console.error);