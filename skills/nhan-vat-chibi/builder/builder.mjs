import fs from 'node:fs/promises';
import path from 'node:path';

const [command, id] = process.argv.slice(2);
const root = path.join(process.cwd(), 'art', 'characters');
const registryPath = path.join(root, 'registry.json');
const dir = path.join(root, id || '');
const arg = (name) => { const i = process.argv.indexOf(name); return i < 0 ? '' : process.argv[i + 1]; };
const has = (name) => process.argv.includes(name);
const validId = /^[a-z0-9][a-z0-9-]{1,48}$/;

async function readRegistry() {
  try { return JSON.parse(await fs.readFile(registryPath, 'utf8')); }
  catch (error) {
    if (error.code !== 'ENOENT') throw error;
    return { schema_version: 1, characters: {} };
  }
}
async function writeRegistry(registry) {
  await fs.mkdir(root, { recursive: true });
  await fs.writeFile(registryPath, JSON.stringify(registry, null, 2) + '\n');
}
async function identity() {
  return JSON.parse(await fs.readFile(path.join(dir, 'identity.json'), 'utf8'));
}
async function saveIdentity(data) {
  await fs.writeFile(path.join(dir, 'identity.json'), JSON.stringify(data, null, 2) + '\n');
}
async function createCharacter(characterId, name, brief) {
  const characterDir = path.join(root, characterId);
  await fs.mkdir(root, { recursive: true });
  await fs.mkdir(characterDir, { recursive: false });
  for (const folder of ['source', 'approved', 'layers', 'review', 'prompts']) {
    await fs.mkdir(path.join(characterDir, folder));
  }
  const data = {
    character_id: characterId,
    display_name: name || characterId,
    profile: 'wuxia-storybook-hybrid',
    status: 'draft',
    design_brief: brief || '',
    palette: { ink: '#49352f', skin: '#f2c6a5', robe: '#587b78', accent: '#c98d52' },
    face_id: {},
    hair_id: {},
    costume_id: {},
    weapon_id: {},
    asymmetry: [],
    locked_traits: [],
    approved_revision: null
  };
  await fs.writeFile(path.join(characterDir, 'identity.json'), JSON.stringify(data, null, 2) + '\n');
  await fs.writeFile(path.join(characterDir, 'review', 'review.md'),
    '# Review — ' + (name || characterId) + '\n\n' +
    '- [ ] Face and identity match the identity brief\n' +
    '- [ ] Hair silhouette, color and accessories are consistent\n' +
    '- [ ] Costume layers, palette and symbols are consistent\n' +
    '- [ ] Anatomy, hands and weapon grip are readable\n' +
    '- [ ] Front / 3-4 / side / back views are consistent\n' +
    '- [ ] Expressions and action poses preserve identity\n' +
    '- [ ] Human visual review approved\n');
  const registry = await readRegistry();
  registry.characters[characterId] = {
    character_id: characterId,
    display_name: data.display_name,
    profile: data.profile,
    status: 'draft',
    workspace: 'art/characters/' + characterId,
    approved_revision: null
  };
  await writeRegistry(registry);
  return data;
}

async function main() {
  if (command === 'list') {
    const registry = await readRegistry();
    const entries = Object.values(registry.characters);
    if (!entries.length) { console.log('Character registry is empty.'); return; }
    for (const item of entries) {
      console.log([item.character_id, item.display_name, item.status, item.approved_revision || '-'].join('\t'));
    }
    return;
  }

  if (!command || !id || !validId.test(id)) {
    throw new Error('Usage: builder.mjs list | init|ensure|prompt|generate|validate|preview|approve|cast <character-id>');
  }

  if (command === 'init' || command === 'ensure') {
    const name = arg('--name') || id;
    const brief = arg('--brief') || '';
    let data;
    try {
      data = await identity();
      if (command === 'init') throw new Error('Character already exists: ' + id + '. Use ensure to reuse it.');
      if (name && name !== id) data.display_name = name;
      if (brief) data.design_brief = brief;
      await saveIdentity(data);
      const registry = await readRegistry();
      registry.characters[id] = {
        ...(registry.characters[id] || {}),
        character_id: id,
        display_name: data.display_name || name,
        profile: data.profile,
        status: data.status,
        workspace: 'art/characters/' + id,
        approved_revision: data.approved_revision || null
      };
      await writeRegistry(registry);
      console.log('EXISTING ' + id + ' — reused existing identity; no duplicate created.');
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      data = await createCharacter(id, name, brief);
      console.log('CREATED ' + id + ' — new character workspace and registry entry created.');
    }
    return;
  }

  const data = await identity();
  if (command === 'cast') {
    if (data.status !== 'approved' || !data.approved_revision) {
      throw new Error('Character is not approved. Review the artwork, then run approve ' + id + ' --human-reviewed.');
    }
    const actorId = arg('--actor-id') || id;
    const entry = {
      actor_id: actorId,
      character_id: id,
      name: data.display_name || id,
      profile: data.profile,
      status: data.status,
      rig: 'full_body_rig_v1',
      asset_dir: 'art/characters/' + id + '/approved/' + data.approved_revision,
      revision: data.approved_revision
    };
    const out = path.join(dir, 'approved', data.approved_revision, 'cast-entry.json');
    await fs.writeFile(out, JSON.stringify(entry, null, 2) + '\n');
    console.log(JSON.stringify(entry, null, 2));
    console.log('Saved cast entry: ' + out);
    return;
  }

  if (command === 'approve') {
    if (!has('--human-reviewed')) {
      throw new Error('Approval requires explicit human review: approve ' + id + ' --human-reviewed');
    }
    const revision = arg('--revision') || (await fs.readFile(path.join(dir, 'source', 'LATEST'), 'utf8')).trim();
    const sourceSvg = path.join(dir, 'source', revision, 'master.svg');
    const validation = await fs.readFile(path.join(dir, 'review', 'validation.txt'), 'utf8');
    if (!validation.includes('STRUCTURE PASS')) throw new Error('Latest validation must pass before approval.');
    const approvedDir = path.join(dir, 'approved', revision);
    await fs.mkdir(approvedDir, { recursive: true });
    await fs.copyFile(sourceSvg, path.join(approvedDir, 'master.svg'));
    data.status = 'approved';
    data.approved_revision = revision;
    await saveIdentity(data);
    const registry = await readRegistry();
    registry.characters[id] = {
      ...(registry.characters[id] || {}),
      character_id: id,
      display_name: data.display_name || id,
      profile: data.profile,
      status: 'approved',
      workspace: 'art/characters/' + id,
      approved_revision: revision
    };
    await writeRegistry(registry);
    console.log('Approved ' + id + ' revision ' + revision);
    return;
  }

  const brief = arg('--brief') || data.design_brief;
  if (command === 'prompt' || command === 'generate') {
    if (!brief) throw new Error('Provide --brief "character description".');
    data.design_brief = brief;
    await saveIdentity(data);
    const identityLock = {
      display_name: data.display_name,
      face_id: data.face_id,
      hair_id: data.hair_id,
      costume_id: data.costume_id,
      weapon_id: data.weapon_id,
      palette: data.palette,
      asymmetry: data.asymmetry,
      locked_traits: data.locked_traits
    };
    const prompt = [
      'You are the sole AI art-and-code model. DeepSeek only; no external image model.',
      'Design an original hand-drawn wuxia chibi storybook character. Do not imitate named characters or actors.',
      'Character ID: ' + id + '. Display name: ' + (data.display_name || id) + '. Brief: ' + brief,
      'IDENTITY LOCK (preserve these traits in every revision and asset): ' + JSON.stringify(identityLock),
      'Do not redesign locked face, hair, costume, palette, asymmetry, symbols or weapon between views/poses. If a field is empty, define it clearly in the SVG and request human approval before treating it as locked.',
      'Create compact articulated chibi anatomy, expressive detailed anime face, distinctive hair silhouette, layered martial-arts robe, readable hands and correct weapon grip.',
      'Return one complete standalone SVG only, no markdown or explanations.',
      'SVG contract: viewBox="0 0 1024 1536", transparent background, full-body 3/4 hero pose.',
      'Use detailed smooth vector paths and restrained cel-shading gradients. Never use stick figure, emoji, primitive icon geometry or rough placeholder.',
      'Use semantic groups with unique IDs: shadow, hair_back, torso, robe_back, thigh_L, shin_L, foot_L, thigh_R, shin_R, foot_R, upper_arm_L, forearm_L, hand_L, upper_arm_R, forearm_R, hand_R, neck, head, hair_front, robe_front, weapon.',
      'Each limb segment must include hidden overlap geometry so joints do not expose gaps when rotated. Keep all groups aligned to the same viewBox.',
      'Face has eyes, irises, pupils, highlights, eyelids, brows, nose, mouth and blush. Costume has crossed collar, layers, sleeves, sash and designed folds.',
      'No script, foreignObject, image, external href, filter, blur or embedded raster.'
    ].join('\n');
    await fs.writeFile(path.join(dir, 'prompts', 'master-prompt.txt'), prompt);
    if (command === 'prompt') { console.log('Prompt saved.'); return; }
    const key = process.env.DEEPSEEK_API_KEY;
    if (!key) throw new Error('Set DEEPSEEK_API_KEY. No provider fallback is allowed.');
    const base = (process.env.DEEPSEEK_BASE_URL || 'https://api.deepseek.com/v1').replace(/\/+$/, '');
    const response = await fetch(base + '/chat/completions', {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + key, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: process.env.DEEPSEEK_MODEL || 'deepseek-chat',
        temperature: 0.7,
        messages: [{ role: 'user', content: prompt }]
      })
    });
    if (!response.ok) throw new Error('DeepSeek API ' + response.status + ': ' + (await response.text()).slice(0, 400));
    const result = await response.json();
    const answer = result.choices[0].message.content.trim()
      .replace(/^```(?:svg|xml)?\s*/i, '')
      .replace(/\s*```$/, '');
    const start = answer.indexOf('<svg'), end = answer.lastIndexOf('</svg>');
    if (start < 0 || end < 0) throw new Error('DeepSeek did not return a complete SVG.');
    const revision = new Date().toISOString().replace(/[:.]/g, '-');
    const target = path.join(dir, 'source', revision);
    await fs.mkdir(target);
    await fs.writeFile(path.join(target, 'master.svg'), answer.slice(start, end + 6));
    await fs.writeFile(path.join(target, 'model.json'), JSON.stringify({
      provider: 'DeepSeek',
      model: result.model || process.env.DEEPSEEK_MODEL || 'deepseek-chat',
      revision,
      character_id: id
    }, null, 2) + '\n');
    await fs.writeFile(path.join(dir, 'source', 'LATEST'), revision);
    data.status = 'draft';
    data.approved_revision = null;
    await saveIdentity(data);
    const registry = await readRegistry();
    if (registry.characters[id]) {
      registry.characters[id].status = 'draft';
      registry.characters[id].approved_revision = null;
      await writeRegistry(registry);
    }
    console.log('Generated revision ' + revision + ' for ' + id + '. Previous revisions are preserved.');
    return;
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
    const required = ['shadow','hair_back','torso','robe_back','thigh_L','shin_L','foot_L','thigh_R','shin_R','foot_R','upper_arm_L','forearm_L','hand_L','upper_arm_R','forearm_R','hand_R','neck','head','hair_front','robe_front','weapon'];
    for (const name of required) if (!new RegExp('id=["\\']' + name + '["\\']').test(svg)) errors.push('Missing full-body rig group: ' + name);
    if ((svg.match(/<path\b/g) || []).length < 25) warnings.push('Fewer than 25 vector paths; inspect detail');
    const report = 'Result: ' + (errors.length ? 'FAIL' : 'STRUCTURE PASS') +
      '\n\nErrors:\n' + (errors.join('\n') || 'None') +
      '\n\nWarnings:\n' + (warnings.join('\n') || 'None') +
      '\n\nStructural pass is not visual approval. Review the artwork manually.';
    await fs.writeFile(path.join(dir, 'review', 'validation.txt'), report);
    console.log(report);
    if (errors.length) process.exitCode = 1;
    return;
  }

  if (command === 'preview') {
    const html = '<!doctype html><meta charset="utf-8"><title>' + id +
      '</title><style>body{margin:0;background:#ddd;display:grid;place-items:center;min-height:100vh}img{max-width:90vw;max-height:90vh}</style><img src="../source/' +
      revision + '/master.svg">';
    await fs.writeFile(path.join(dir, 'review', 'preview.html'), html);
    console.log('Open ' + path.join(dir, 'review', 'preview.html'));
    return;
  }
  throw new Error('Unknown command: ' + command);
}

main().catch(error => { console.error(error.message); process.exitCode = 1; });
