"""Local documentation drawing only. Run after export.exs; no production evaluator."""
from pathlib import Path
import json,html,math
p=Path(__file__).parent;m=json.loads((p/'geometry-witness.json').read_text());refs={x['id']:x for x in m['references']}
def text(x,y,s,size=13):return f'<text x="{x}" y="{y}" font-size="{size}" fill="#334e43">{html.escape(s)}</text>'
def project(v,view='elevation'):
 x,y,z=v
 if view=='plan':u,v=x,z
 elif view=='oblique':u,v=.8*x-.6*z,.3*x+y+.4*z
 else:u,v=x,y
 return 160+u*40,370-v*30
def line(points,color='#779687',view='elevation',closed=False):
 pts=points+([points[0]] if closed else [])
 return f'<polyline points="'+ ' '.join(f'{a:.3f},{b:.3f}' for a,b in [project(v,view) for v in pts])+f'" fill="none" stroke="{color}" stroke-width="2"/>'
def ref(id,view='elevation'):return line(refs[id]['points'],color=('#3d7a75' if id=='diagonal-B' else '#b18b46' if id=='diagonal-A' else '#779687'),view=view,closed=refs[id]['kind']=='closed')
def box(x,y,label,sub=''):
 return f'<rect x="{x}" y="{y}" width="190" height="72" rx="6" fill="#e8eedf" stroke="#a7b89e"/>'+text(x+10,y+26,label)+text(x+10,y+49,sub,10)
def rel(nodes):
 out=''
 for i,(a,b) in enumerate(nodes):
  x=40+(i%3)*230;y=130+(i//3)*120;out+=box(x,y,a,b)
  if i%3<2 and i+1<len(nodes):out+=f'<path d="M {x+192} {y+36} h 34" stroke="#a58a50" marker-end="url(#arrow)"/>'
 return out
def surface(coil,color):
 out=''
 for seg in coil['segments']:
  for face in seg['faces']:
   pts=' '.join(f'{x:.3f},{y:.3f}' for x,y in [project(v,'oblique') for v in face])
   out+=f'<polygon points="{pts}" fill="{color}" fill-opacity="0.22" stroke="{color}" stroke-width="0.35"/>'
 return out
specs={
'A':('Human HERE locality','PLAN / exploration-six-v1; placements CANDIDATE, locality distinctions ESTABLISHED',ref('HERE','plan')+ref('NEXT','plan')+ref('human-circle','plan')+text(160,400,'HERE square / circular seated locality')+text(160,180,'NEXT remains distinct')+box(480,130,'HERE pillar','ZERO→SIX continuous; Seat ONE'), 'IDs HERE, NEXT, human-circle, pillar; actual physical mounting unproved.'),
'B':('Six-extent elevation','ELEVATION XY; required heights / candidate horizontal placements',ref('diagonal-A')+ref('diagonal-B')+ref('pillar')+ref('xt-to-xt-from-here')+ref('table')+ref('seat')+text(420,185,'SIX')+text(420,280,'THREE / Table')+text(420,340,'ONE / Seat')+text(420,378,'ZERO / Ground')+text(40,110,'A: Ground-to-ceiling bearing. B: current-turn XT TOWARD YT length.')+text(40,450,'B endpoints [0,6,0] → [6,0,0]; THROUGH center [3,3,0]')+text(40,478,'Actual length SIX√2 = 8.485281; frame height SIX; inherited local unit ONE')+text(40,506,'XT TO XT FROM HERE → current-turn measure → prospective YT TOWARD YT'), 'B furnished measure; next YT TOWARD YT not furnished; physical joining point unappointed.'),
'C':('Projectioning relationship','RELATIONAL DIAGRAM; not a material transform',rel([('FT source','authored material identity'),('Staged position','provided, unacquired'),('Projectioning Crossing','THREE / source provenance'),('Apparent projection','same source; optical law open'),('OVER ACROSS standing','acquisition blocked'),('Physical monitor','distinct from both apertures')]), 'Actual source ≠ stage ≠ projection ≠ acquired FROM; optical curvature unproved.'),
'D':('Reciprocal offices / Craft','RELATIONAL + registration references; no decorative transported avatar',rel([('FT COB','provides material FROM XT TO XT'),('Projectioning Crossing','issuance ancestry retained'),('TF COB','takes inherited furnishing'),('Seat ONE / Craft reference','physical hull unproved'),('Human FROM HERE','fixed circular locality'),('Acquired frame required','no working COB mounted here')]), 'Office identities differ from bearings/turn types. Craft source version must be reviewed.'),
'E':('Circle–square–triangle','OBLIQUE projection of occupied specimen and registered references',ref('HERE','oblique')+ref('human-circle','oblique')+ref('diagonal-A','oblique')+''.join(line(face,'#987544','oblique',True) for face in m['specimen']['faces']), 'Material table-janusite-specimen: finite trial prism, ordered hinge; no curvature proof.'),
'F':('Two-Footing underfold comparison','OBLIQUE / constant-radius-underfold-v1; candidate 2 REJECTED', ''.join(surface(c,'#b05e5e' if i else '#b08d4b') for i,c in enumerate(m['coils']))+text(40,125,'Common aperture center [3,3,0]')+text(40,430,'Older depth 1.5; newest proposed depth 2.25, nearest Ground')+text(40,455,'Occupied common-aperture interference: accepted coil 1 retained.'), 'IDs coil-candidate-1/2. Finite faces in geometry-witness.json; no infinite packing or acquisition.'),
'G':('Tunnel condition / buttoning','RELATIONAL dependency diagram; separate stipulated condition fixture',rel([('Encounter / local receipt','persistent FROM ZERO'),('At least ONE condition','appointment ≠ satisfaction'),('Exit satisfied','not a new tunnel'),('RE-STOMPING / state','+ COB RE-ZIPPERING required'),('Already-furnished next','eligibility ≠ encounter'),('PENDING UN-BUTTONING','activation/passage still distinct')]), 'Real frame unacquired; fixture success cannot authorize real traversal.'),
'H':('Shared FT / TF Gallery map','PLAN of same candidate geometry; no pre-populated Gallery',ref('HERE','plan')+ref('NEXT','plan')+''.join(line(c['points'],'#b48650','plan') for c in m['coils'])+text(430,240,'Common entrances coincide')+text(430,265,'No emerging axle curvature proven'), 'No actual acquired Footings; selection is inspection. Candidate axle ≠ invariant HERE pillar.'),
'I':('Flat / Tunnel correspondence','SAME WORLD POINTS; candidate screen mapping, not optical law',ref('diagonal-A')+ref('table')+ref('monitor')+text(450,165,'Full-square flat source')+text(450,195,'Half-screen u = 100 + 16x')+text(450,225,'Full-screen u = 100 + 32x')+text(450,255,'World vertices unchanged')+text(450,285,'Inner/material apertures distinct'), 'No final public left/right arrangement. Material extent remains SIX despite screen appearance.'),
'J':('Constitutional sequence','RELATIONAL dependency sketch; unresolved total physical securing order',rel([('Already-furnished room','frame / capacity / Ground machinery'),('Human selectioning','PITTONING / RE-STOMPING'),('RE-ZIPPERING / confirm','protected acquisition blocked'),('Lawful FROM-standing','required before COB works'),('Local Footing accretion','conditions / exit / return'),('Ceiling occasion','does not advance RE-STEP index')]), 'Necessary witness dependencies do not fabricate actual completed acquisition.')}
for key,(title,kind,body,note) in specs.items():
 svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="820" height="650" viewBox="0 0 820 650" role="img" aria-labelledby="title desc"><title id="title">{html.escape(title)}</title><desc id="desc">{html.escape(kind+'; '+note)}</desc><defs><marker id="arrow" markerWidth="7" markerHeight="7" refX="6" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6" fill="#a58a50"/></marker></defs><rect width="820" height="650" fill="#f8faf2"/>{text(30,40,key+' · '+title,22)}{text(30,70,kind,11)}{body}{text(30,580,note,10)}{text(30,610,m['frame']['geometry_version']+' · source: GeometryExploration + commission/addendum',10)}</svg>'''
 (p/(key+'.svg')).write_text(svg)
print('Generated A–J from shared geometry JSON and qualified relational drawings.')

# Additional v3 witnesses: finite source geometry, not a production evaluator.
if (p/'staging-witness.json').exists():
 st=json.loads((p/'staging-witness.json').read_text())
 def sp(v,view,base,scale=140):
  x,y,z=v;x-=3;y-=3
  u,w=(x,z) if view=='plan' else (z,y) if view=='transverse' else (x,y)
  return base[0]+u*scale,base[1]-w*scale
 def sl(points,view,base,color,closed=False):
  pts=points+([points[0]] if closed else [])
  return '<polyline points="'+' '.join(f'{a:.3f},{b:.3f}' for a,b in [sp(v,view,base) for v in pts])+f'" fill="none" stroke="{color}" stroke-width="2"/>'
 def ss(material,view,base):
  color={'already_standing_reference':'#658888','newly_staged':'#c39348'}.get(material['status'],'#688c59');out=''
  for face in material['faces']:
   pts=' '.join(f'{a:.3f},{b:.3f}' for a,b in [sp(v,view,base) for v in face])
   out+=f'<polygon points="{pts}" fill="{color}" fill-opacity=".38" stroke="{color}" stroke-width=".7"/>'
  return out
 def write_staging(key,title,subtitle,body,note):
  (p/(key+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="820" height="650" viewBox="0 0 820 650" role="img" aria-labelledby="title desc"><title id="title">{html.escape(title)}</title><desc id="desc">{html.escape(subtitle+"; "+note)}</desc><rect width="820" height="650" fill="#f8faf2"/>{text(30,40,key+" · "+title,22)}{text(30,75,subtitle,11)}{body}{text(30,570,note,10)}{text(30,615,st["geometry_contract"]+" · AlongsideStaging source / preview only",10)}</svg>')
 staged=st['staged'];body=''
 for view,base in [('flat',(220,285)),('transverse',(590,285))]:
  body+=text(base[0]-100,130,view+' · identical source IDs',14)
  body+=sl(staged['aperture']['points'],view,base,'#36899a')
  for material in staged['materials']:body+=ss(material,view,base)
 body+=text(30,410,'inherited reference: already-standing fixture / actual acquisition NOT ATTESTED')
 body+=text(30,440,'new material: STAGED ALONGSIDE / UP FROM HERE, FROM OVER ACROSS / NOT ACQUIRED')
 body+=text(30,470,'Both share the UN-VANISHING registered opening; physical transfer remains unproved.')
 body+=text(30,510,'FROM DOWN UNDER requires later lawful Landinging acquisition; it is not a camera relabeling.')
 write_staging('K','Staging alongside / UN-VANISHING','FLAT + TRANSVERSE / exploration-six-v1 / finite candidate specimens',body,'No acquired frame or COB working is attested; aperture profile is the same boundary, not new optics.')
 angular=st['angular'];base=(210,330);body=sl(angular['axle']['points'],'plan',base,'#9a6999')
 for material in angular['materials']:
  body+=ss(material,'plan',base)
  x,y=sp(material['center'],'plan',base)
  body+=f'<circle cx="{x}" cy="{y}" r="4" fill="#9a6999"/>'+text(x+8,y-10,str(material['angle'])+'°',12)
 body+=box(470,150,'Camera pivot ≠ material bend','Explicit appointment precedes staging')
 body+=box(470,245,'Control deflection '+str(round(angular['axle']['deflections'][0],3))+'°','Derived from retained source centers')
 body+=text(30,430,'Reference 0° → explicit candidate furnishing 30° → explicit candidate furnishing 60°')
 body+=text(30,465,'Only retained source centers form the control. No pre-drawn spiral or occupied axle.')
 body+=text(30,500,'Lawful acquisition and joined JANUSITE curvature remain unproved; same SIX frame persists.')
 write_staging('L','Angular relationships / candidate axle','PLAN / same material registry / control polygon only',body,'Camera/appointment/staging/furnishing/acquisition remain separate. FT/TF working authority is not granted.')
 print('Generated K/L finite staging and angular-registration witnesses.')
