return {
	['Powersource'] = {
		['DrainedPS'] = 'Pure Energeian Elemental Orb',
		['order'] = {
			[1] = 'PsEnabled',
			[2] = 'GoodPS',
			[3] = 'DrainedPS',
			[4] = 'GoodPSAggroMin',
		},
		['PsEnabled'] = 'On',
		['GoodPSAggroMin'] = '1',
		['GoodPS'] = 'Pure Energeian Metal Orb',
	},
	['Burn'] = {
		['SmallBurnIf'] = '${If[${Me.XTarget}>=4,1,0]}',
		['SBurn2'] = 'Ancestral Aid|alt',
		['SBurn3'] = 'Spirit Call|alt',
		['SBurn4'] = 'Focus of Arcanum|alt',
		['order'] = {
			[1] = 'BurnAllNamed',
			[2] = 'SmallWithBig',
			[3] = 'UseTribute',
			[4] = 'BigBurnIf',
			[5] = 'SmallBurnIf',
			[6] = 'BBurn1',
			[7] = 'BBurn2',
			[8] = 'BBurn3',
			[9] = 'BBurn4',
			[10] = 'BBurn5',
			[11] = 'BBurn6',
			[12] = 'BBurn7',
			[13] = 'BBurn8',
			[14] = 'SBurn1',
			[15] = 'SBurn2',
			[16] = 'SBurn3',
			[17] = 'SBurn4',
			[18] = 'SBurn5',
			[19] = 'SBurn6',
			[20] = 'SBurn7',
			[21] = 'SBurn8',
		},
		['BBurn1'] = 'Rabid Bear|alt',
		['SBurn6'] = 'NULL',
		['BBurn2'] = 'Barbarian Hunting Spear|item',
		['SBurn8'] = 'NULL',
		['BBurn3'] = 'NULL',
		['SBurn7'] = 'NULL',
		['BBurn4'] = 'NULL',
		['SBurn5'] = 'Dampen Resistance|alt',
		['BBurn5'] = 'NULL',
		['BurnAllNamed'] = 'Off',
		['BBurn6'] = 'NULL',
		['SmallWithBig'] = 'On',
		['BBurn7'] = 'NULL',
		['UseTribute'] = 'Off',
		['BBurn8'] = 'NULL',
		['BigBurnIf'] = '${If[${Me.Song[Fierce Eye].ID},1,0]}',
		['SBurn1'] = 'Spire of Ancestors|alt',
	},
	['Shaman'] = {
		['AAMalo'] = 'On',
		['AASingleTurgurs'] = 'On',
		['Regen'] = 'Off',
		['AEMaloAA'] = 'On',
		['AETurgurs'] = 'On',
		['order'] = {
			[1] = 'AACanniAt',
			[2] = 'AAMalo',
			[3] = 'AASingleTurgurs',
			[4] = 'AEMalo',
			[5] = 'AESlow',
			[6] = 'AEMaloAA',
			[7] = 'AETurgurs',
			[8] = 'AncAidAt',
			[9] = 'AncGuardAt',
			[10] = 'Aura',
			[11] = 'CanniAt',
			[12] = 'CallOfWild',
			[13] = 'Champion',
			[14] = 'Cripple',
			[15] = 'Cures',
			[16] = 'EpicOnCD',
			[17] = 'EpicWithBardSK',
			[18] = 'Feralize',
			[19] = 'Focus',
			[20] = 'HealGroupPets',
			[21] = 'HealWardAt',
			[22] = 'HoTTank',
			[23] = 'GroupShrink',
			[24] = 'Malo',
			[25] = 'Panther',
			[26] = 'Regen',
			[27] = 'RezMeLast',
			[28] = 'RezOOC',
			[29] = 'RezStick',
			[30] = 'SelfDI',
			[31] = 'SlothTank',
			[32] = 'Slow',
			[33] = 'SoothsayersAt',
			[34] = 'SoW',
			[35] = 'UnresMalo',
			[36] = 'UnionAt',
			[37] = 'Ward',
			[38] = 'WildGrowthTank',
		},
		['AncGuardAt'] = '30',
		['CanniAt'] = '80',
		['Aura'] = 'On',
		['CallOfWild'] = 'On',
		['Champion'] = 'On',
		['Cures'] = 'On',
		['EpicOnCD'] = 'Off',
		['EpicWithBardSK'] = 'On',
		['HealGroupPets'] = 'On',
		['HealWardAt'] = '60',
		['HoTTank'] = 'On',
		['GroupShrink'] = 'On',
		['AESlow'] = 'On|3',
		['RezMeLast'] = 'On',
		['AEMalo'] = 'On|3',
		['RezOOC'] = 'On',
		['RezStick'] = 'On',
		['Focus'] = 'On',
		['SlothTank'] = 'On',
		['WildGrowthTank'] = 'Off',
		['Ward'] = 'On',
		['Malo'] = 'Off',
		['SoW'] = 'On',
		['UnionAt'] = '55',
		['Slow'] = 'On',
		['Panther'] = 'On',
		['SoothsayersAt'] = '30',
		['UnresMalo'] = 'Off',
		['SelfDI'] = 'On',
		['Feralize'] = 'On',
		['AncAidAt'] = '45',
		['AACanniAt'] = '60',
		['Cripple'] = 'On',
	},
	['Combat'] = {
		['DoTStop'] = '10',
		['Melee'] = 'Off',
		['AESlow'] = 'Grezan\'s Drowse',
		['AEMalo'] = 'Wind of Malis',
		['Cripple'] = 'Crippling Spasm',
		['DebuffAt'] = '100',
		['UnresMalo'] = 'Malis',
		['DDs'] = 'On',
		['Malo'] = 'Malosenea',
		['DoTs'] = 'Named',
		['Feralize'] = 'Feralization',
		['Slow'] = 'Balance of Discord',
		['DDAt'] = '99',
		['TimeAntithesis'] = 'On',
		['DoTAt'] = '99',
		['AttackRange'] = '100',
		['DebuffStop'] = '20',
		['AttackAt'] = '99',
		['order'] = {
			[1] = 'AttackAt',
			[2] = 'AttackRange',
			[3] = 'DebuffAt',
			[4] = 'DDs',
			[5] = 'DoTs',
			[6] = 'DDAt',
			[7] = 'DoTAt',
			[8] = 'DebuffStop',
			[9] = 'DDStop',
			[10] = 'DoTStop',
			[11] = 'Melee',
			[12] = 'TimeAntithesis',
			[13] = 'AESlow',
			[14] = 'AEMalo',
			[15] = 'Cripple',
			[16] = 'Feralize',
			[17] = 'Malo',
			[18] = 'Slow',
			[19] = 'UnresMalo',
		},
		['DDStop'] = '5',
	},
	['General'] = {
		['Med'] = 'On',
		['MedStart'] = '60',
		['XTarHeal'] = 'On',
		['ChaseDistance'] = '30',
		['MedCombat'] = 'Off',
		['UseDNet'] = 'On',
		['MedStop'] = '90',
		['order'] = {
			[1] = 'ReturnToCamp',
			[2] = 'ChaseAssist',
			[3] = 'ChaseDistance',
			[4] = 'Buffs',
			[5] = 'Med',
			[6] = 'MedStart',
			[7] = 'MedStop',
			[8] = 'MedCombat',
			[9] = 'UseDNet',
			[10] = 'XTarHeal',
			[11] = 'XTarHealList',
		},
		['ChaseAssist'] = 'Off',
		['XTarHealList'] = '3',
		['ReturnToCamp'] = 'Off',
		['Buffs'] = 'On',
	},
	['Buffs'] = {
		['Sloth'] = 'Listlessness',
		['FocusBuff'] = 'Darkpaw Focusing',
		['Regen'] = 'Talisman of the Resolute',
		['SoW'] = 'Spirit of Bih`li',
		['SelfDI'] = 'Second Life',
		['Ward'] = 'Ward of Restoration',
		['Panther'] = 'Talisman of the Lynx',
		['Canni'] = 'Ancestral Obligation',
		['KeywordAll'] = 'allbuffz',
		['order'] = {
			[1] = 'Canni',
			[2] = 'Focus',
			[3] = 'FocusBuff',
			[4] = 'SoW',
			[5] = 'Panther',
			[6] = 'SelfDI',
			[7] = 'Growth',
			[8] = 'Sloth',
			[9] = 'Regen',
			[10] = 'Ward',
			[11] = 'KeywordAll',
			[12] = 'KeywordCustom',
		},
		['KeywordCustom'] = 'buffz',
		['Growth'] = 'Wild Growth',
		['Focus'] = 'Talisman of Unity',
	},
	['Pet'] = {
		['PetAssist'] = '99',
		['PetRange'] = '115',
		['order'] = {
			[1] = 'PetHold',
			[2] = 'PetAssist',
			[3] = 'PetRange',
			[4] = 'PetShrink',
		},
		['PetShrink'] = 'On',
		['PetHold'] = 'On',
	},
	['KeywordCustom'] = {
		['Regen'] = 'Off',
		['SoW'] = 'On',
		['order'] = {
			[1] = 'Focus',
			[2] = 'SoW',
			[3] = 'Regen',
		},
		['Focus'] = 'On',
	},
	['Heals'] = {
		['Heal4'] = 'NULL',
		['GroupHealTarCountMin'] = '3',
		['GroupHeal2'] = 'NULL',
		['CancelHealAt'] = '95',
		['GroupClick1'] = 'Tarnished Fategaze Chain Coat          ',
		['InterruptToHeal'] = 'On',
		['GroupClick2'] = 'NULL',
		['Panic1'] = 'Antecedent\'s Intervention',
		['order'] = {
			[1] = 'HealPanicAt',
			[2] = 'HealRegularAt',
			[3] = 'HealTankAt',
			[4] = 'HoTAt',
			[5] = 'GroupHealAt',
			[6] = 'GroupHealTarCountMin',
			[7] = 'CancelHealAt',
			[8] = 'InterruptToHeal',
			[9] = 'Panic1',
			[10] = 'Panic2',
			[11] = 'Panic3',
			[12] = 'Panic4',
			[13] = 'Panic5',
			[14] = 'PanicClick1',
			[15] = 'PanicClick2',
			[16] = 'Heal1',
			[17] = 'Heal2',
			[18] = 'Heal3',
			[19] = 'Heal4',
			[20] = 'Heal5',
			[21] = 'HealClicky1',
			[22] = 'HealClicky2',
			[23] = 'HealClicky3',
			[24] = 'HoT',
			[25] = 'GroupHeal1',
			[26] = 'GroupHeal2',
			[27] = 'GroupClick1',
			[28] = 'GroupClick2',
		},
		['Panic2'] = 'NULL',
		['GroupHeal1'] = 'Shadow of Renewal',
		['HoT'] = 'Halcyon Whisper',
		['Panic3'] = 'NULL',
		['HealRegularAt'] = '65',
		['Panic4'] = 'NULL',
		['HealClicky2'] = 'NULL',
		['Panic5'] = 'NULL',
		['HealPanicAt'] = '40',
		['PanicClick1'] = 'NULL',
		['HealClicky1'] = 'NULL         ',
		['PanicClick2'] = 'NULL',
		['Heal5'] = 'NULL',
		['Heal1'] = 'Dannal\'s Mending',
		['HealTankAt'] = '75',
		['HealClicky3'] = 'NULL',
		['Heal2'] = 'NULL',
		['HoTAt'] = '90',
		['Heal3'] = 'NULL',
		['GroupHealAt'] = '85',
	},
	['Spells'] = {
		['DoT4'] = 'NULL',
		['CurseGrp'] = 'NULL',
		['CurseSing'] = 'Remove Greater Curse',
		['PetBuff1'] = 'Spirit Quickening',
		['Gift'] = 'Frost Gift',
		['MiscGem'] = '7',
		['DD1'] = 'Ice Sheet',
		['MiscGemRemem'] = 'On',
		['DD2'] = 'Bite of the Ukun',
		['PetShrink'] = 'Tiny Companion',
		['PetBuff2'] = 'NULL',
		['Radiant'] = 'On',
		['PetSum'] = 'Aina\'s Faithful',
		['DisGrp'] = 'Blood of Avoling',
		['LoadSpellSet'] = 'Box',
		['DoT2'] = 'Mojo',
		['DisSing'] = 'Disinfecting Aura',
		['DPSClicky2'] = 'NULL',
		['DoT1'] = 'Breath of Queen Malarian',
		['PoiGrp'] = 'Blood of Avoling',
		['DPSClicky1'] = 'Mysaphar\'s Silverfanged Coat',
		['PoiSing'] = 'Disinfecting Aura',
		['DD3'] = 'NULL',
		['CorrGrp'] = 'Chant of the Burnyai',
		['DoT3'] = 'Blood of Jaled`Dar',
		['order'] = {
			[1] = 'MiscGem',
			[2] = 'MiscGemRemem',
			[3] = 'LoadSpellSet',
			[4] = 'Radiant',
			[5] = 'DisGrp',
			[6] = 'DisSing',
			[7] = 'PoiGrp',
			[8] = 'PoiSing',
			[9] = 'CorrGrp',
			[10] = 'CorrSing',
			[11] = 'CurseGrp',
			[12] = 'CurseSing',
			[13] = 'Gift',
			[14] = 'DD1',
			[15] = 'DD2',
			[16] = 'DD3',
			[17] = 'DPSClicky1',
			[18] = 'DPSClicky2',
			[19] = 'DoT1',
			[20] = 'DoT2',
			[21] = 'DoT3',
			[22] = 'DoT4',
			[23] = 'PetSum',
			[24] = 'PetBuff1',
			[25] = 'PetBuff2',
			[26] = 'PetShrink',
		},
		['CorrSing'] = 'Cure Corruption',
	},
}