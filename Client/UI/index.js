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
var current_asset_pack = "NanosWorld";

var assets = {
	NanosWorld: {
		props: [
			{name: "SM_Cone", image: "https://i.imgur.com/sKjbueM.jpg"},
			{name: "SM_Cube", image: "https://i.imgur.com/OcyUjXp.jpg"},
			{name: "SM_Cylinder", image: "https://i.imgur.com/nkPvu96.jpg"},
			{name: "SM_Plane", image: "https://i.imgur.com/ls0cD9b.jpg"},
			{name: "SM_Sphere", image: "https://i.imgur.com/aClqtmd.jpg"},
			{name: "Test", image: ""},
		],
		weapons: [
			{name: "AK47", image: "https://i.imgur.com/FXVEclZ.png"}
		],
		vehicles: [
			{name: "Pickup", image: "https://i.imgur.com/FXVEclZ.png"}
		],
		tools: [
			{name: "PiToolckup", image: "https://i.imgur.com/FXVEclZ.png"}
		]
	}
};

function SpawnItemClick(e) {
	let asset_id = $(e).data("asset_id");
	let asset_pack = $(e).data("asset_pack");
	Events.Call("SpawnItem", asset_pack, current_tab, asset_id);
}

function ItemHover(label, enter) {
	if (enter)
	{
		$("#label").css("opacity", '1');
		$("#label").html(label);
		Events.Call("HoverSound");
	}
	else
	{
		$("#label").css("opacity", '0');
	}
}

function AssetPackClick(e) {
	let new_asset_pack = $(e).html();

	if (new_asset_pack == current_asset_pack)
		return;

	current_asset_pack = new_asset_pack;

	console.log("eba")
	console.log(current_asset_pack)
	RefreshAssets();

	$(".asset_pack.active").removeClass("active");
	$(e.target).addClass("active");
}

function TabClick(e) {
	let new_tab = $(e.target).attr("id");

	if (new_tab == current_tab)
		return;

	current_tab = new_tab;

	RefreshAssets();

	$(".tab.active").removeClass("active");
	$(e.target).addClass("active");
}

function RefreshAssets() {
	$("#spawn_list").html("");

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

$(document).ready(function() {

	$(".tab").click(TabClick);

	$(".tab").mouseenter(function(e) { ItemHover($(e.target).children(".tab_name").html(), true); });
	$(".tab").mouseleave(function(e) { ItemHover(false, false); });

	// AddAssetPack("NanosWorld", JSON.stringify(assets.NanosWorld));
	// AddAssetPack("NanosWorld2", JSON.stringify(assets.NanosWorld));

	// current_asset_pack = $(".asset_pack").first().html();
	// current_tab = $(".tab").attr("id");

	// RefreshAssets();

	// $(".tab").first().click();
	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");
	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");

	// InsertItem("SM_Cone", "https://i.imgur.com/sKjbueM.jpg");
	// InsertItem("SM_Cube", "https://i.imgur.com/OcyUjXp.jpg");
	// InsertItem("SM_Cylinder", "https://i.imgur.com/nkPvu96.jpg");
	// InsertItem("SM_Plane", "https://i.imgur.com/ls0cD9b.jpg");
	// InsertItem("SM_Sphere", "https://i.imgur.com/aClqtmd.jpg");
});

function DisplayAsset(asset_pack, asset_id, asset_name, image) {
	if (!image) image = "images/nanosworld_empty.png";
	
	let spawn_item = $("<span class='spawn_item' onclick='SpawnItemClick(this)' onmouseenter='ItemHover(\"" + asset_name + "\", true);' onmouseleave='ItemHover(\"" + asset_name + "\", false);'>");
	let spawn_item_image = $("<span class='spawn_item_image'>");
	let spawn_item_name = $("<span class='spawn_item_name'>");
	spawn_item.data("asset_pack", asset_pack);
	spawn_item.data("asset_id", asset_id);
	
	spawn_item_image.css("background-image", "url('" + image + "')");
	spawn_item_name.html(asset_name);

	spawn_item.append(spawn_item_image);
	spawn_item.append(spawn_item_name);

	$("#spawn_list").append(spawn_item);
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
	if (is_visible)
		$("#spawn_menu").show();
	else
		$("#spawn_menu").hide();
});