UselessGun = ToolGun.Inherit("UselessGun")

UselessGun.useless_websites = {
	"https://longdogechallenge.com/",
	"https://puginarug.com",
	"https://floatingqrcode.com/",
	"https://heeeeeeeey.com/",
	"http://corndog.io/",
	"http://www.staggeringbeauty.com/",
	"http://burymewithmymoney.com/",
	"https://smashthewalls.com/",
	"http://endless.horse/",
	"http://www.republiquedesmangues.fr/",
	"http://www.movenowthinklater.com/",
	"http://www.rrrgggbbb.com/",
	"https://rotatingsandwiches.com/",
	"http://randomcolour.com/",
	"http://maninthedark.com/",
	"http://cat-bounce.com/",
	"http://chrismckenzie.com/",
	"http://ninjaflex.com/",
	"http://ihasabucket.com/",
	"http://corndogoncorndog.com/",
	"http://www.hackertyper.com/",
	"http://www.nullingthevoid.com/",
	"http://www.muchbetterthanthis.com/",
	"http://www.yesnoif.com/",
	"http://lacquerlacquer.com",
	"http://potatoortomato.com/",
	"http://doughnutkitten.com/",
	"http://crouton.net/",
	"http://corgiorgy.com/",
	"http://www.wutdafuk.com/",
	"http://unicodesnowmanforyou.com/",
	"http://chillestmonkey.com/",
	"http://scroll-o-meter.club/",
	"http://www.crossdivisions.com/",
	"http://tencents.info/",
	"https://boringboringboring.com/",
	"http://www.patience-is-a-virtue.org/",
	"http://pixelsfighting.com/",
	"https://existentialcrisis.com/",
	"http://www.omfgdogs.com/",
	"http://oct82.com/",
	"http://chihuahuaspin.com/",
	"http://www.blankwindows.com/",
	"http://www.trashloop.com/",
	"http://spaceis.cool/",
	"http://www.doublepressure.com/",
	"http://buildshruggie.com/",
	"http://yeahlemons.com/",
	"http://notdayoftheweek.com/",
	"https://card.toys",
	"https://greatbignothing.com/",
	"https://zoomquilt.org/",
	"https://dadlaughbutton.com/",
	"http://papertoilet.com/",
	"https://loopedforinfinity.com/",
	"https://www.ripefordebate.com/",
	"https://elonjump.com/",
	"https://www.bouncingdvdlogo.com/",
	"https://optical.toys/thatcher-effect/",
	"https://optical.toys/troxler-fade/",
	"https://optical.toys/bamboozled/",
	"https://optical.toys/dots-that-wont-quit/",
	"https://optical.toys/lilac-chaser/",
	"https://optical.toys/cafe-wall/",
	"https://optical.toys/kaleidoscope/",
	"https://optical.toys/motion-aftereffect/",
	"https://optical.toys/illusory-motion-beans/",
	"https://optical.toys/reverse-phi-effect/",
	-- "https://optical.toys",
}

function UselessGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.GREEN)
end

function UselessGun:OnUselessObject(player, entity, hit_location, direction)
	-- Picks up a random website
	local website = UselessGun.useless_websites[math.random(#UselessGun.useless_websites)]

	Events.BroadcastRemote("MakeObjectUseless", entity, website)

	Particle(hit_location, direction:Rotation(), "nanos-world::P_DirectionalBurst")
end

UselessGun.SubscribeRemote("UselessObject", UselessGun.OnUselessObject)