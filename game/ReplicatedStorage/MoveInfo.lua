local module = {}

module.GB = {
	Kungfu = {
		Name = '<u>STOMP</u>(10s)',
		Effects = '<mark><font color="rgb(255,0,0)">GUARDBREAK</font></mark>',
		Desc = 'After a delay, unleash a stomp that <mark><b><font color="rgb(255,0,0)">guardbreaks</font></b></mark> anyone hit. This deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	},
	SwordDude = {
		Name = '<u>CHARGED SLASH</u>(9s)',
		Effects = '<mark><font color="rgb(255,0,0)">GUARDBREAK</font></mark>',
		Desc = 'Hold your sword with two hands, bring it over your head and backward, and slash forward after a delay. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	},
	Sheriff = {
		Name = '<u>BLASTBREAKER</u>(8s)',
		Effects = '<mark><font color="rgb(255,0,0)">GUARDBREAK</font></mark>',
		Desc = 'Unleash a concussive blast in front of yourself to shatter the guard of anyone hit. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	},
	Medic = {
		Name = '<u>TRANQUILIZER DART</u>(12s)',
		Effects = '<mark><font color="rgb(255,0,0)">IGNORES BLOCK</font></mark>',
		Desc = 'Shoot a dart loaded with sedatives that put the enemy to <mark><b><font color="rgb(26, 255, 221)">sleep</font></b></mark> for <mark><font color="rgb(0, 2, 175)">4s</font></mark>.'
	},
	Savage = {
		Name = '<u>BARBARIC SWEEP</u>(8s)',
		Effects = '<mark><font color="rgb(255,0,0)">GUARDBREAK</font></mark>',
		Desc = 'Perform a sweeping attack with both of your blades shattering the opponent’s guard. This deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	}
}

module.AB1 = {
	Kungfu = {
		Name = '<u>SPIN KICK</u>(11s)',
		Effects = '<mark><font color="rgb(64, 0, 255)">SUPERARMOUR</font></mark>',
		Desc = 'Spin with one of your hands on the ground knocking enemies away. This move has <mark><b><font color="rgb(64, 0, 255)">superarmour</font></b></mark> and deals <mark><b><font color="rgb(255,255,0)">15</font></b></mark> damage. Knocks away enemies even if <mark><b><font color="rgb(52, 52, 52)">blocked</font></b></mark>.'
	},
	SwordDude = {
		Name = '<u>QUICK JABS</u>(11s)',
		Effects = '<mark><font color="rgb(64, 0, 255)">SUPERARMOUR</font></mark>',
		Desc = 'Jab your sword forward multiple times in quick succession. Can be used as a <mark><b><font color="rgb(255, 244, 90)">combo starter</font></b></mark>. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage in total.'
	},
	Sheriff = {
		Name = '<u>QUICKDRAW DUEL</u>(13s)',
		Effects = '',
		Desc = 'Enter a rapid-fire stance, allowing you to quickly fire multiple shots with exceptional speed. Each bullet deals <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage and the last bullet <mark><b><font color="rgb(255,0,0)">guardbreaks</font></b></mark>. Shoot bullets by mouse1. Ends by running out of bullets or recasting this ability.'
	},
	Medic = {
		Name = '<u>TRIAGE AMMUNITION</u>(2x, 10s)',
		Effects = '',
		Desc = 'Shoot a dart which has different effect based on type:<br /><mark><b><font color="rgb(0,0,0)">CRIPPLING AMMO</font></b></mark>: Does <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage and applies <mark><b><font color="rgb(0,0,0)">cripple</font></b></mark> for <mark><font color="rgb(0, 2, 175)">5s</font></mark>.<br /><mark><b><font color="rgb(255, 63, 5)">SHATTER DART</font></b></mark>: Does <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage, <mark><b><font color="rgb(255,0,0)">ignores block</font></b></mark>, and applies <mark><b><font color="rgb(150,0,0)">-15% attack</font></b></mark> for <mark><b><font color="rgb(0, 2, 175)">5s</font></b></mark>.<br /><mark><b><font color="rgb(100, 255, 92)">REGEN DART</font></b></mark>: <mark><b><font color="rgb(0, 255, 0)">Heals</font></b></mark> anyone hit for 6 health.'
	},
	Savage = {
		Name = '<u>FERAL STRIKE</u>(12s)',
		Effects = '',
		Desc = 'Lunge forward with a feral strike, inflicting damage to anyone hit. Can be used as a <mark><b><font color="rgb(255, 244, 90)">combo starter</font></b></mark>. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	}
} 

module.AB2 = {
	Kungfu = {
		Name = '<u>BIG PUNCH</u>(14s)',
		Effects = '<mark><font color="rgb(255,0,0)">GUARDBREAK</font></mark>, <mark><font color="rgb(64, 0, 255)">SUPERARMOUR</font></mark>',
		Desc = 'Charge and unleash a powerful punch. Shockwave of the punch travels further. Deals <mark><b><font color="rgb(255,255,0)">20-10</font></b></mark> damage depending on distance and has <mark><b><font color="rgb(64, 0, 255)">superarmour</font></b></mark> after the startup. <mark><b><font color="rgb(255,0,0)">Guardbreaks</font></b></mark> if the enemy is close enough.'
	},
	SwordDude = {
		Name = '<u>Armour Pericer</u>(12s)',
		Effects = '<mark><font color="rgb(255,0,0)">IGNORES BLOCK</font></mark>',
		Desc = 'Slash forward cutting through enemy’s defenses. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage and applies a <mark><b><font color="rgb(255,0,0)">-20% defence</font></b></mark> debuff for <mark><b><font color="rgb(0, 2, 175)">6s</font></b></mark>.'
	},
	Sheriff = {
		Name = '<u>DEADEYE SHOT</u>(13s)',
		Effects = '<mark><font color="rgb(255,0,0)">IGNORES BLOCK</font></mark>',
		Desc = 'The player takes careful aim and delivers a precise, high-impact shot with high accuracy and <mark><b><font color="rgb(255,255,0)">15</font></b></mark> damage.'
	},
	Medic = {
		Name = '<u>GRENADE THROW</u>(2x, 13s)',
		Effects = '',
		Desc = 'Throw a grenade that has different effect based on type:<br /><mark><b><font color="rgb(156, 0, 156)">TOXIC VIAL</font></b></mark>: Does <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage and applies <mark><b><font color="rgb(175, 0, 175)">poison(5s)</font></b></mark>.<br /><mark><b><font color="rgb(255, 255, 0)">ADRENALINE BOMB</font></b></mark>: Does <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage and applies <mark><b><font color="rgb(0, 0, 255)">slow(15%)</font></b></mark> for <mark><b><font color="rgb(0, 2, 175)">5s</font></b></mark>. Allies get <mark><b><font color="rgb(0, 157, 255)">haste(20%)</font></b></mark> for <mark><b><font color="rgb(0, 2, 175)">5s</font></b></mark>.<br /><mark><b><font color="rgb(100, 255, 92)">MEDI-GRENADE</font></b></mark>:  Gives allies <mark><b><font color="rgb(0, 255, 0)">regeneration(2hp/sec)</font></b></mark> for <mark><font color="rgb(0, 2, 175)">5s</font></mark>. Duration for user is <mark><font color="rgb(0, 2, 175)">3s</font></mark>.'
	},
	Savage = {
		Name = '<u>SERRATED SLASHES</u>(13s)',
		Effects = '',
		Desc = 'Perform a quick flurry of slashes. Last hit applies <mark><b><font color="rgb(200,0,0)">bleed(4s)</font></b></mark>. Deals <mark><b><font color="rgb(255,255,0)">14</font></b></mark> damage.'
	}
}
module.AB3 = {
	Kungfu = {
		Name = '<u>LEG BREAKER</u>(11s)',
		Effects = '',
		Desc = 'Kick your enemy’s leg making them slow down. Deals <mark><b><font color="rgb(255,255,0)">7</font></b></mark> damage and applies <mark><b><font color="rgb(0, 0, 255)">slow(30%)</font></b></mark> for <mark><b><font color="rgb(0, 2, 175)">6s</font></b></mark>. If <mark><b><font color="rgb(52, 52, 52)">blocked</font></b></mark>, apply <mark><b><font color="rgb(0, 0, 255)">slow(30%)</font></b></mark> and teleport behind the enemy.'
	},
	SwordDude = {
		Name = '<u>AIR CUTTER</u>(12s)',
		Effects = '',
		Desc = 'Cut the air in front of you making a slash projectile that travels further. Deals <mark><b><font color="rgb(255,255,0)">12</font></b></mark> damage.'
	},
	Sheriff = {
		Name = '<u>RELOAD DASH</u>(15s)',
		Effects = '',
		Desc = 'Dash forward while reloading your gun. Resets the cooldown of <mark><b><font color="rgb(0, 132, 255)">Deadeye Shot</font></b></mark>.<br /><b>[ALT]:</b> If used during <mark><b><font color="rgb(0, 132, 255)">Quickdraw Duel</font></b></mark>, reload three bullets while dashing forward'
	},
	Medic = {
		Name = '<u>SWITCH</u>(3s)',
		Effects = '',
		Desc = 'Allows the player to switch between ammo and grenade types by pressing E or R respectively. Recast to exit switching mode.'
	},
	Savage = {
		Name = '<u>DEATH’S EMBRACE</u>(14s)',
		Effects = '<mark><font color="rgb(255,0,0)">IGNORES BLOCK</font></mark>',
		Desc = 'Deliver a powerful dual-blade finisher. If the player hit is close enough, deal <mark><b><font color="rgb(255,255,0)">15</font></b></mark> damage and <mark><b><font color="rgb(130,0,0)">execute</font></b></mark> them if they are left below 10% health. If the player hit is far, deal <mark><b><font color="rgb(255,255,0)">8</font></b></mark> damage.'
	}
}
return module
