// Registers for ToggleVoice from Scripting
Events.Subscribe("ToggleVoice", function(name, enable) {
	const existing_span = document.querySelector(`.voice_chat#${name}`);

	if (enable) {
		if (existing_span)
			return;

		const span = document.createElement("span");
		span.classList.add("voice_chat");
		span.id = name;
		span.innerHTML = name;

		document.querySelector("#voice_chats").prepend(span);
	} else {
		if (!existing_span)
			return;

		existing_span.remove();
	}
});

// Registers for Notifications from Scripting
Events.Subscribe("AddNotification", function(message, time) {
	const span = document.createElement("span");
	span.classList.add("notification");
	span.innerHTML = message;

	document.querySelector("#notifications").prepend(span);

	setTimeout(function(span) {
		span.remove()
	}, time, span);
});

// Register for UpdateWeaponAmmo custom event (from Lua)
Events.Subscribe("UpdateWeaponAmmo", function(enable, clip, bag) {
	if (enable)
		document.querySelector("#weapon_ammo_container").style.display = "block";
	else
		document.querySelector("#weapon_ammo_container").style.display = "none";

	// Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
	document.querySelector("#weapon_ammo_clip").innerHTML = clip;
	document.querySelector("#weapon_ammo_bag").innerHTML = bag;
});

// Register for UpdateHealth custom event (from Lua)
Events.Subscribe("UpdateHealth", function(health) {
	// Overrides the HTML content of the SPAN with the new health value
	document.querySelector("#health_current").innerHTML = health;

	// Bonus: make the background red when health below 25
	document.querySelector("#health_container").style.backgroundColor = health <= 25 ? "#ff05053d" : "#0000003d";
});

Events.Subscribe("ToggleScoreboard", function(enable) {
	const scoreboard = document.querySelector("#scoreboard");

	if (enable)
		scoreboard.style.display = "block";
	else
		scoreboard.style.display = "none";
});

Events.Subscribe("UpdatePlayer", function(id, active, name, ping) {
	const existing_scoreboard_entry = document.querySelector(`#scoreboard_entry_id${id}`);

	if (active) {
		if (existing_scoreboard_entry) {
			const scoreboard_ping = existing_scoreboard_entry.querySelector("td.scoreboard_ping");
			scoreboard_ping.innerHTML = ping;
			return;
		}

		const scoreboard_entry_tr = document.createElement("tr");
		scoreboard_entry_tr.id = `scoreboard_entry_id${id}`;

		const scoreboard_entry_td_id = document.createElement("td");
		scoreboard_entry_td_id.className = "scoreboard_id";
		scoreboard_entry_td_id.innerHTML = id;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_id);
		
		const scoreboard_entry_td_name = document.createElement("td");
		scoreboard_entry_td_name.className = "scoreboard_name";
		scoreboard_entry_td_name.innerHTML = name;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_name);
		
		const scoreboard_entry_td_ping = document.createElement("td");
		scoreboard_entry_td_ping.className = "scoreboard_ping";
		scoreboard_entry_td_ping.innerHTML = ping;
		scoreboard_entry_tr.appendChild(scoreboard_entry_td_ping);

		document.querySelector("#scoreboard_tbody").prepend(scoreboard_entry_tr);
	} else {
		if (!existing_scoreboard_entry)
			return;

		existing_scoreboard_entry.remove();
	}
});



var current_tab = "props";
var current_asset_pack =  "nanos-world";

var assets = {
	NanosWorld: {
		props: [],
		weapons: [],
		vehicles: [],
		tools: [],
		npcs: [],
	}
};

function SpawnItemClick(e) {
	const asset_id = e.target.dataset.asset_id;
	const asset_pack = e.target.dataset.asset_pack;
	Events.Call("SpawnItem", asset_pack, current_tab, asset_id);
}

function ItemHover(label, enter) {
	const label_element = document.querySelector("#label");

	if (enter) {
		label_element.style.opacity = 1; 
		label_element.innerHTML = label;
		Events.Call("HoverSound");
	} else {
		label_element.style.opacity = 0; 
	}
}

// function AssetPackClick(e) {
// 	let new_asset_pack = $(e).html();

// 	if (new_asset_pack == current_asset_pack)
// 		return;

// 	current_asset_pack = new_asset_pack;

// 	RefreshAssets();

// 	$(".asset_pack.active").removeClass("active");
// 	$(e.target).addClass("active");
// }

function TabClick(e) {
	const new_tab = e.target.getAttribute("id");

	if (new_tab == current_tab)
		return;

	current_tab = new_tab;

	RefreshAssets();

	document.querySelector(".tab.active").classList.remove("active");
	e.target.classList.add("active");
}

function RefreshAssets() {
	document.querySelector("#spawn_list").innerHTML = "";

	if (!assets[current_asset_pack]) {
		console.error("Failed to get props from Asset Pack: '" + current_asset_pack + "'.");
		return;
	}

	if (!assets[current_asset_pack][current_tab])
		return;

	// For now, let's just load all assets
	for (let asset_pack in assets) {
		for (let asset_pack_item in assets[asset_pack][current_tab]) {
			let item = assets[asset_pack][current_tab][asset_pack_item];
			DisplayAsset(asset_pack, item.id, item.name, item.image);
		}
	}

	// for (let i = 0; i < assets[current_asset_pack][current_tab].length; i++) {
	// 	DisplayAsset(assets[current_asset_pack][current_tab][i].name, assets[current_asset_pack][current_tab][i].image);
	// }
}

document.addEventListener("DOMContentLoaded", function(event) {
	const tabs = document.querySelectorAll(".tab");

	for (let i = 0; i < tabs.length; i++) {
		const tab = tabs[i];

		tab.addEventListener('click', TabClick);
		tab.addEventListener('mouseenter', function(e) { ItemHover(tab.querySelector(".tab_name").innerHTML, true); });
		tab.addEventListener('mouseleave', function(e) { ItemHover(false, false); });
	} 
});

function DisplayAsset(asset_pack, asset_id, asset_name, image) {
	if (!image) image = "images/nanosworld_empty.png";

	const spawn_item = document.createElement("span");
	spawn_item.classList.add("spawn_item");
	spawn_item.addEventListener('click', SpawnItemClick);
	spawn_item.addEventListener('onmouseenter', e => ItemHover(asset_name, true));
	spawn_item.addEventListener('onmouseleave', e => ItemHover(false, false));

	const spawn_item_image = document.createElement("span");
	spawn_item_image.classList.add("spawn_item_image");

	const spawn_item_name = document.createElement("span");
	spawn_item_name.classList.add("spawn_item_name");

	spawn_item.dataset.asset_pack = asset_pack;
	spawn_item.dataset.asset_id = asset_id;
	
	spawn_item_image.style["background-image"] = `url('${image}')`;
	spawn_item_name.innerHTML = asset_name;

	spawn_item.appendChild(spawn_item_image);
	spawn_item.appendChild(spawn_item_name);

	document.querySelector("#spawn_list").appendChild(spawn_item);
}

function AddAssetPack(asset_pack_name, data) {
	assets[asset_pack_name] = JSON.parse(data);

	// let asset_pack = $("<span class='asset_pack' style='background-image: url(\"images/nanosworld.png\");' onclick='AssetPackClick(this)' onmouseenter='ItemHover(\"" + asset_pack_name + "\", true);' onmouseleave='ItemHover(\"" + asset_pack_name + "\", false);'>" + asset_pack_name + "</span>");

	// $("#asset_packs").append(asset_pack);

	// if (current_asset_pack == asset_pack_name)
	// {
	// 	asset_pack.addClass("active");
		RefreshAssets();
	// }
}

Events.Subscribe("AddAssetPack", AddAssetPack);

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.querySelector("#spawn_menu");

	if (is_visible)
		spawn_menu.style.display = "block";
	else
		spawn_menu.style.display = "none";
});