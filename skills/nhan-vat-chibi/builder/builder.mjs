import fs from 'node:fs/promises';
import path from 'node:path';

const [command, id] = process.argv.slice(2);
const root = path.join(process.cwd(), 'art', 'characters');
const dir = path.join(root, id || '');
const arg = (name) => { const i = process.argv.indexOf(name); return i < 0 ? '' : process.argv[i + 1]; };
const validId = /^[a-z0-9][a-z0-9-]{1,48}$/;
async function identity() { return JSON.parse(await fs.readFile(path.join(dir, 'identity.json'), 'utf8')); }
async function main() {
  if (!command || !id || !validId.test(id)) throw new Error('Usage: node skills/nhan-vat-chibi/builder/builder.mjs init|prompt|generate|validate|preview <id>');
  if (command === 'init') {
    await fs.mkdir(root, { recursive: true });
    await fs.mkdir(dir, { recursive: false });
    for (const name of ['source', 'approved', 'layers', 'review', 'prompts']) await fs.mkdir(path.join(dir, name));
    await fs.writeFile(path.join(dir, 'identity.json'), JSON.stringify({ character_id:id, profile:'wuxia-storybook-hybrid', status:'draft', design_brief:'', palette:{ink:'#49352f',skin:'#f2c6a5',robe:'#587b78',accent:'#c98d52'}, face_id:{}, hair_id:{}, costume_id:{}, weapon_id:{}, asymmetry:[], approved_revision:null }, null, 2));
    await fs.writeFile(path.join(dir, 'review', 'review.md'), '# Review\n\n- [ ] Face and identity\n- [ ] Anatomy and silhouette\n- [ ] Costume and palette\n- [ ] Hands and weapon grip\n- [ ] Human approval\n');
    console.log('Created ' + dir); return;
  }
  const data = await identity();
  const brief = arg('--brief') || data.design_brief;
  if (command === 'prompt' || command === 'generate') {
    if (!brief) throw new Error('Provide --brief "character description".');
    data.design_brief = brief;
    await fs.writeFile(path.join(dir, 'identity.json'), JSON.stringify(data, null, 2));
    const prompt = [
      'You are the sole AI art-and-code model. DeepSeek only; no external image model.',
      'Design an original hand-drawn wuxia chibi storybook character. Do not imitate named characters.',
      'Character: ' + id + '. Brief: ' + brief,
      'Palette: ' + JSON.stringify(data.palette),
      'Create articulated compact anatomy, expressive detailed anime face, designed hair silhouette, layered martial-arts robe, clear hands and correct weapon grip.',
      'Return one complete standalone SVG only, no markdown or explanations.',
      'SVG contract: viewBox="0 0 1024 1536", transparent background, full body 3/4 hero pose.',
      'Use detailed smooth vector paths and restrained cel-shading gradients. Never use stick figure, emoji, primitive icon geometry or rough placeholder.',
      'Use semantic groups with unique IDs: shadow, hair_back, body, robe_back, legs, arms_back, head, hair_front, arms_front, robe_front, weapon.',
      'Face has eyes, irises, pupils, highlights, eyelids, brows, nose, mouth and blush. Costume has crossed collar, layers, sleeves, sash and designed folds.',
      'No script, foreignObject, image, external href, filter, blur or embedded raster.'
    ].join('\n');
    await fs.writeFile(path.join(dir, 'prompts', 'master-prompt.txt'), prompt);
    if (command === 'prompt') { console.log('Prompt saved.'); return; }
    const key = process.env.DEEPSEEK_API_KEY;
    if (!key) throw new Error('Set DEEPSEEK_API_KEY. No provider fallback is allowed.');
    const base = (process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1').replace(/\/+$/, '');
    const response = await fetch(base + '/chat/completions', { method:'POST', headers:{ Authorization:'Bearer ' + key, 'Content-Type':'application/json' }, body:JSON.stringify({ model:process.env.DEEPSEEK_MODEL || 'deepseek-chat', temperature:0.7, messages:[{role:'user',content:prompt}] }) });
    if (!response.ok) throw new Error('DeepSeek API ' + response.status + ': ' + (await response.text()).slice(0,400));
    const result = await response.json();
    const answer = result.choices[0].message.content.trim().replace(/^\`\`\`(?:svg|xml)?\s*/i,'').replace(/\s*\`\`\`$/,'');
    const start = answer.indexOf('<svg'), end = answer.lastIndexOf('</svg>');
    if (start < 0 || end < 0) throw new Error('DeepSeek did not return a complete SVG.');
    const revision = new Date().toISOString().replace(/[:.]/g,'-');
    const target = path.join(dir, 'source', revision);
    await fs.mkdir(target);
    await fs.writeFile(path.join(target, 'master.svg'), answer.slice(start, end + 6));
    await fs.writeFile(path.join(target, 'model.json'), JSON.stringify({provider:'DeepSeek',model:result.model || process.env.DEEPSEEK_MODEL || 'deepseek-chat',revision},null,2));
    await fs.writeFile(path.join(dir, 'source', 'LATEST'), revision);
    console.log('Generated revision ' + revision); return;
  }
  const revision = (await fs.readFile(path.join(dir, 'source', 'LATEST'), 'utf8')).trim();
  const svgPath = path.join(dir, 'source', revision, 'master.svg');
  const svg = await fs.readFile(svgPath, 'utf8');
  if (command === 'validate') {
    const errors = [], warnings = [];
    if (!svg.includes('<svg') || !svg.includes('</svg>')) errors.push('Missing SVG root');
    if (!/viewBox=["']0 0 1024 1536["']/.test(svg)) errors.push('Expected 1024x1536 viewBox');
    if (/<(script|foreignObject|image)\b/i.test(svg)) errors.push('Forbidden element');
    if (/\b(?:href|xlink:href)=["'](?!#)/i.test(svg)) errors.push('External href');
    const ids = [...svg.matchAll(/\bid=["']([^"']+)["']/g)].map(x => x[1]);
    if (new Set(ids).size !== ids.length) errors.push('Duplicate IDs');
    for (const name of ['head','hair_back','hair_front','body','robe_front','weapon']) if (!svg.includes('id="' + name + '"')) warnings.push('Missing group ' + name);
    if ((svg.match(/<path\b/g) || []).length < 25) warnings.push('Fewer than 25 vector paths; inspect detail');
    const report = 'Result: ' + (errors.length ? 'FAIL' : 'STRUCTURE PASS') + '\n\nErrors:\n' + (errors.join('\n') || 'None') + '\n\nWarnings:\n' + (warnings.join('\n') || 'None') + '\n\nStructural pass is not visual approval.';
    await fs.writeFile(path.join(dir, 'review', 'validation.txt'), report);
    console.log(report); if (errors.length) process.exitCode = 1; return;
  }
  if (command === 'preview') {
    const html = '<!doctype html><meta charset="utf-8"><title>' + id + '</title><style>body{margin:0;background:#ddd;display:grid;place-items:center;min-height:100vh}img{max-width:90vw;max-height:90vh}</style><img src="../source/' + revision + '/master.svg">';
    await fs.writeFile(path.join(dir, 'review', 'preview.html'), html);
    console.log('Open ' + path.join(dir, 'review', 'preview.html')); return;
  }
  throw new Error('Unknown command: ' + command);
}
main().catch(error => { console.error(error.message); process.exitCode = 1; });
