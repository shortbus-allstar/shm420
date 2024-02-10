return {
	['colife'] = {
		['name'] = 'Barbarian Hunting Spear',
		['tar'] = 'None',
		['cond'] = '${If[${SpawnCount[npc radius 50 zradius 10]}>=5 && ${Me.CombatState.Equal[COMBAT]},1,0]}',
		['type'] = 'item',
	},
	['Rabid Bear'] = {
		['tar'] = 'None',
		['type'] = 'alt',
		['cond'] = '${If[${SpawnCount[npc radius 50 zradius 10]}>=5 && ${Me.CombatState.Equal[COMBAT]},1,0]}',
		['name'] = 'Rabid Bear',
	},
	['newcond'] = {
		['name'] = '',
		['tar'] = 'None',
		['cond'] = '',
		['type'] = 'item',
	},
	['healpot'] = {
		['name'] = 'Distillate of Celestial Healing XV',
		['tar'] = 'None',
		['cond'] = '${If[${Me.PctHPs}<=45,1,0]}',
		['type'] = 'item',
	},
	['Spire of Ancestors'] = {
		['name'] = 'Spire of Ancestors',
		['type'] = 'alt',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
		['tar'] = 'None',
	},
	['Spirit Call'] = {
		['tar'] = 'MA Target',
		['type'] = 'alt',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
		['name'] = 'Spirit Call',
	},
	['Ancestral Aid'] = {
		['tar'] = 'None',
		['type'] = 'alt',
		['cond'] = '${If[(${Me.Song[Fierce Eye].ID}||${Target.Named}) && ${Me.CombatState.Equal[COMBAT]},1,0]}',
		['name'] = 'Ancestral Aid',
	},
}