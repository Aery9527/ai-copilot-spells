#!/usr/bin/env node

/**
 * 將 skill 的 SKILL.md 中的 graphviz 圖表渲染為 SVG 檔案。
 *
 * 用法：
 *   ./render-graphs.js <skill-directory>           # 分別渲染每個圖表
 *   ./render-graphs.js <skill-directory> --combine # 將所有圖表合併為一個
 *
 * 從 SKILL.md 提取所有 ```dot 區塊並渲染為 SVG。
 * 用於幫助你的人類夥伴視覺化流程圖。
 *
 * 需求：系統上已安裝 graphviz（dot）
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function extractDotBlocks(markdown) {
  const blocks = [];
  const regex = /```dot\n([\s\S]*?)```/g;
  let match;

  while ((match = regex.exec(markdown)) !== null) {
    const content = match[1].trim();

    // 提取 digraph 名稱
    const nameMatch = content.match(/digraph\s+(\w+)/);
    const name = nameMatch ? nameMatch[1] : `graph_${blocks.length + 1}`;

    blocks.push({ name, content });
  }

  return blocks;
}

function extractGraphBody(dotContent) {
  // 從 digraph 中只提取本體（節點和邊）
  const match = dotContent.match(/digraph\s+\w+\s*\{([\s\S]*)\}/);
  if (!match) return '';

  let body = match[1];

  // 移除 rankdir（我們在頂層統一設定一次）
  body = body.replace(/^\s*rankdir\s*=\s*\w+\s*;?\s*$/gm, '');

  return body.trim();
}

function combineGraphs(blocks, skillName) {
  const bodies = blocks.map((block, i) => {
    const body = extractGraphBody(block.content);
    // 將每個子圖包裝在 cluster 中以進行視覺分組
    return `  subgraph cluster_${i} {
    label="${block.name}";
    ${body.split('\n').map(line => '  ' + line).join('\n')}
  }`;
  });

  return `digraph ${skillName}_combined {
  rankdir=TB;
  compound=true;
  newrank=true;

${bodies.join('\n\n')}
}`;
}

function renderToSvg(dotContent) {
  try {
    return execSync('dot -Tsvg', {
      input: dotContent,
      encoding: 'utf-8',
      maxBuffer: 10 * 1024 * 1024
    });
  } catch (err) {
    console.error('執行 dot 時發生錯誤：', err.message);
    if (err.stderr) console.error(err.stderr.toString());
    return null;
  }
}

function main() {
  const args = process.argv.slice(2);
  const combine = args.includes('--combine');
  const skillDirArg = args.find(a => !a.startsWith('--'));

  if (!skillDirArg) {
    console.error('用法：render-graphs.js <skill-directory> [--combine]');
    console.error('');
    console.error('選項：');
    console.error('  --combine    將所有圖表合併為一個 SVG');
    console.error('');
    console.error('範例：');
    console.error('  ./render-graphs.js ../subagent-driven-development');
    console.error('  ./render-graphs.js ../subagent-driven-development --combine');
    process.exit(1);
  }

  const skillDir = path.resolve(skillDirArg);
  const skillFile = path.join(skillDir, 'SKILL.md');
  const skillName = path.basename(skillDir).replace(/-/g, '_');

  if (!fs.existsSync(skillFile)) {
    console.error(`錯誤：找不到 ${skillFile}`);
    process.exit(1);
  }

  // 確認 dot 是否可用
  try {
    execSync('which dot', { encoding: 'utf-8' });
  } catch {
    console.error('錯誤：找不到 graphviz（dot）。安裝方式：');
    console.error('  brew install graphviz    # macOS');
    console.error('  apt install graphviz     # Linux');
    process.exit(1);
  }

  const markdown = fs.readFileSync(skillFile, 'utf-8');
  const blocks = extractDotBlocks(markdown);

  if (blocks.length === 0) {
    console.log('在', skillFile, '中找不到 ```dot 區塊');
    process.exit(0);
  }

  console.log(`在 ${path.basename(skillDir)}/SKILL.md 中找到 ${blocks.length} 個圖表`);

  const outputDir = path.join(skillDir, 'diagrams');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir);
  }

  if (combine) {
    // 將所有圖表合併為一個
    const combined = combineGraphs(blocks, skillName);
    const svg = renderToSvg(combined);
    if (svg) {
      const outputPath = path.join(outputDir, `${skillName}_combined.svg`);
      fs.writeFileSync(outputPath, svg);
      console.log(`  已渲染：${skillName}_combined.svg`);

      // 同時寫入 dot 原始碼供除錯用
      const dotPath = path.join(outputDir, `${skillName}_combined.dot`);
      fs.writeFileSync(dotPath, combined);
      console.log(`  原始碼：${skillName}_combined.dot`);
    } else {
      console.error('  合併圖表渲染失敗');
    }
  } else {
    // 分別渲染每個圖表
    for (const block of blocks) {
      const svg = renderToSvg(block.content);
      if (svg) {
        const outputPath = path.join(outputDir, `${block.name}.svg`);
        fs.writeFileSync(outputPath, svg);
        console.log(`  已渲染：${block.name}.svg`);
      } else {
        console.error(`  失敗：${block.name}`);
      }
    }
  }

  console.log(`\n輸出位置：${outputDir}/`);
}

main();
