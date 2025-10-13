document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the ammo
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<!-- Weapon Ammo container (black background) -->
		<div id="weapon_ammo_container">
			<!-- Ammo Clip value -->
			<span id="weapon_ammo_clip">30</span>
			<span id="weapon_ammo_separator">/</span>
			<!-- Ammo Bag value -->
			<span id="weapon_ammo_bag">1000</span>
		</div>
	`);
});

// Register for UpdateWeaponAmmo custom event (from Lua)
function UpdateWeaponAmmo(enable, clip, bag) {
	if (enable)
		document.getElementById("weapon_ammo_container").style.display = "block";
	else
		document.getElementById("weapon_ammo_container").style.display = "none";

	// Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
	document.getElementById("weapon_ammo_clip").innerHTML = clip;
	document.getElementById("weapon_ammo_bag").innerHTML = bag;
}

Events.Subscribe("UpdateWeaponAmmo", UpdateWeaponAmmo);