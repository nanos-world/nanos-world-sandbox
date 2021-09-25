// Registers for ToggleVoice from Scripting
function ToggleVoice(name, enable) {
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
}

// Registers for Notifications from Scripting
function AddNotification(message, time) {
	const span = document.createElement("span");
	span.classList.add("notification");
	span.innerHTML = message;

	document.querySelector("#notifications").prepend(span);

	setTimeout(function(span) {
		span.remove()
	}, time, span);
}

// Register for UpdateWeaponAmmo custom event (from Lua)
function UpdateWeaponAmmo(enable, clip, bag) {
	if (enable)
		document.querySelector("#weapon_ammo_container").style.display = "block";
	else
		document.querySelector("#weapon_ammo_container").style.display = "none";

	// Using JQuery, overrides the HTML content of these SPANs with the new Ammo values
	document.querySelector("#weapon_ammo_clip").innerHTML = clip;
	document.querySelector("#weapon_ammo_bag").innerHTML = bag;
}

// Register for UpdateHealth custom event (from Lua)
function UpdateHealth(health) {
	// Overrides the HTML content of the SPAN with the new health value
	document.querySelector("#health_current").innerHTML = health;

	// Bonus: make the background red when health below 25
	document.querySelector("#health_container").style.backgroundColor = health <= 25 ? "#ff05053d" : "#0000003d";
}

function ToggleScoreboard(enable) {
	const scoreboard = document.querySelector("#scoreboard");

	if (enable)
		scoreboard.style.display = "block";
	else
		scoreboard.style.display = "none";
}

function UpdatePlayer(id, active, name, ping) {
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
}



var current_category = "";
var current_tab = "props";
var current_asset_pack =  "nanos-world";

var assets = {
	NanosWorld: {
		props: [],
		weapons: [],
		// entities: [],
		vehicles: [],
		tools: [],
		npcs: [],
	}
};

// TODO move to Lua?
var categories = {
	props: [
		{ id: "basic", label: "Basic", image_active: "images/categories/shapes.png", image_inactive: "images/categories/shapes-disabled.png" },
		{ id: "appliances", label: "Appliances", image_active: "images/categories/appliances.png", image_inactive: "images/categories/appliances-disabled.png" },
		{ id: "construction", label: "Construction", image_active: "images/categories/construction.png", image_inactive: "images/categories/construction-disabled.png" },
		{ id: "furniture", label: "Furniture", image_active: "images/categories/lamp.png", image_inactive: "images/categories/lamp-disabled.png" },
		{ id: "funny", label: "Funny", image_active: "images/categories/joker-hat.png", image_inactive: "images/categories/joker-hat-disabled.png" },
		{ id: "tools", label: "Tools", image_active: "images/categories/tools.png", image_inactive: "images/categories/tools-disabled.png" },
		{ id: "food", label: "Food", image_active: "images/categories/hot-dog.png", image_inactive: "images/categories/hot-dog-disabled.png" },
		{ id: "street", label: "Street", image_active: "images/categories/street-lamp.png", image_inactive: "images/categories/street-lamp-disabled.png" },
		{ id: "nature", label: "Nature", image_active: "images/categories/tree.png", image_inactive: "images/categories/tree-disabled.png" },
		{ id: "uncategorized", label: "Uncategorized", image_active: "images/categories/menu.png", image_inactive: "images/categories/menu-disabled.png" },
	],
	weapons: [
		{ id: "rifles", label: "Rifles", image_active: "images/categories/rifle.png", image_inactive: "images/categories/rifle-disabled.png" },
		{ id: "smgs", label: "SMGs", image_active: "images/categories/smg.png", image_inactive: "images/categories/smg-disabled.png" },
		{ id: "pistols", label: "Pistols", image_active: "images/categories/revolver.png", image_inactive: "images/categories/revolver-disabled.png" },
		{ id: "shotguns", label: "Shotguns", image_active: "images/categories/shotgun.png", image_inactive: "images/categories/shotgun-disabled.png" },
		{ id: "sniper-rifles", label: "Sniper Rifles", image_active: "images/categories/sniper-rifle.png", image_inactive: "images/categories/sniper-rifle-disabled.png" },
		{ id: "special", label: "Special", image_active: "images/categories/laser-gun.png", image_inactive: "images/categories/laser-gun-disabled.png" },
		{ id: "grenades", label: "Grenade", image_active: "images/categories/grenade.png", image_inactive: "images/categories/grenade-disabled.png" },
	],
	// entities: [],
	vehicles: [],
	tools: [],
	npcs: [],
}

function SpawnItemClick(e) {
	const asset_id = e.target.dataset.asset_id;
	const asset_pack = e.target.dataset.asset_pack;
	Events.Call("SpawnItem", asset_pack, current_tab, asset_id);
}

function ItemHover(label, enter, is_spawn_item) {
	const label_element = document.querySelector("#label");

	if (enter) {
		label_element.style.opacity = 1; 
		label_element.innerHTML = label;
		Events.Call("HoverSound", is_spawn_item ? 1 : 0.9);
	} else {
		label_element.style.opacity = 0; 
	}
}

function TabClick(tab_element) {
	const new_tab = tab_element.dataset.tab_id;

	if (current_tab == "weapons")
		ToggleOptions(false);
	else if (new_tab == "weapons")
		ToggleOptions(true);

	current_tab = new_tab;

	// Clears Categories List
	document.querySelector("#spawn_categories").innerHTML = "";

	for (let category in categories[current_tab]) {
		const item = categories[current_tab][category];
		AddCategory(item.id, item.label, item.image_active, item.image_inactive);
	}

	AddCategory("all", "All", "images/categories/infinity.png", "images/categories/infinity-disabled.png");

	CategoryClick(document.querySelectorAll(".spawn_category")[0]);

	const old_tab_active = document.querySelector(".tab.active");
	if (old_tab_active) {
		old_tab_active.classList.remove("active");
		const old_tab_image = old_tab_active.querySelector("img");
		old_tab_image.src = old_tab_active.dataset.image_inactive;
	}

	tab_element.classList.add("active");

	const tab_image = tab_element.querySelector("img");
	tab_image.src = tab_element.dataset.image_active;
}

function CategoryClick(category_item) {
	const new_category = category_item.dataset.category_id;

	current_category = new_category;

	RefreshAssets();

	const old_category_active = document.querySelector(".spawn_category.active");
	if (old_category_active) {
		old_category_active.classList.remove("active");
		old_category_active.style["background-image"] = `url('${old_category_active.dataset.image_inactive}')`;
	}

	category_item.classList.add("active");
	category_item.style["background-image"] = `url('${category_item.dataset.image_active}')`;

	Events.Call("ClickSound");
}

function AddCategory(id, name, image_active, image_inactive) {
	const category = document.createElement("span");
	category.classList.add("spawn_category");
	category.addEventListener("click", e => CategoryClick(e.target));
	category.addEventListener("mouseenter", e => ItemHover("Category: " + e.target.dataset.category_name, true));
	category.addEventListener("mouseleave", e => ItemHover(false, false));

	category.dataset.category_id = id;
	category.dataset.category_name = name;
	category.dataset.image_active = image_active;
	category.dataset.image_inactive = image_inactive;

	category.style["background-image"] = `url('${image_inactive}')`;

	document.querySelector("#spawn_categories").appendChild(category);
}

function AddTab(id, name, image_active, image_inactive) {
	const tab = document.createElement("span");
	tab.classList.add("tab");
	tab.addEventListener("click", e => TabClick(e.target));
	tab.addEventListener("mouseenter", e => ItemHover("Tab: " + e.target.dataset.tab_name, true));
	tab.addEventListener("mouseleave", e => ItemHover(false, false));

	const tab_image = document.createElement("img");
	tab_image.src = image_inactive;

	const tab_name = document.createElement("span");
	tab_name.classList.add("tab_name");
	tab_name.innerHTML = name;

	tab.appendChild(tab_image);
	tab.appendChild(tab_name);

	tab.dataset.tab_id = id;
	tab.dataset.tab_name = name;
	tab.dataset.image_active = image_active;
	tab.dataset.image_inactive = image_inactive;

	document.querySelector("#tabs").appendChild(tab);
}

function RefreshAssets() {
	// Clears Spawn List
	document.querySelector("#spawn_list").innerHTML = "";

	if (!assets[current_asset_pack]) {
		// TODO fix, it's calling it multiple times triggering this error
		// console.error("Failed to get props from Asset Pack: '" + current_asset_pack + "'.");
		return;
	}

	if (!assets[current_asset_pack][current_tab])
		return;

	// For now, let's just load all assets
	for (let asset_pack in assets) {
		for (let asset_pack_item in assets[asset_pack][current_tab]) {
			const item = assets[asset_pack][current_tab][asset_pack_item];

			// Filter category
			if (current_category != "all" && item.sub_category != current_category)
				continue;

			DisplayAsset(asset_pack, item.id, item.name, item.image);
		}
	}
}

function ToggleOptions(enable) {
	const spawn_list = document.querySelector("#spawn_list");
	const spawn_options = document.querySelector("#spawn_options");

	if (enable) {
		spawn_options.style.display = "block";
		spawn_list.style.right = "200px";
	} else {
		spawn_options.style.display = "none";
		spawn_list.style.right = "0";
	}
}

function SelectOption(element) {
	const texture_path = element.dataset.texture;

	const old_option_selected = document.querySelector(".spawn_option_checkbox_item.selected");
	if (old_option_selected)
		old_option_selected.classList.remove("selected");

	element.classList.add("selected");

	Events.Call("SelectOption", texture_path);
}

function AddOption(name, texture, texture_thumbnail) {
	// Todo this is completely wrong, just an workaround for now, we must make it generic
	
	const option_checkbox_item = document.createElement("span");
	option_checkbox_item.classList.add("spawn_option_checkbox_item");
	option_checkbox_item.style.backgroundImage = `url('${texture_thumbnail || texture}'), url("./images/empty-set.png")`;

	option_checkbox_item.dataset.name = name;
	option_checkbox_item.dataset.texture = texture;

	option_checkbox_item.addEventListener('click', e => SelectOption(e.target));
	option_checkbox_item.addEventListener('mouseenter', e => ItemHover("Pattern: " + e.target.dataset.name, true, true));
	option_checkbox_item.addEventListener('mouseleave', e => ItemHover(false, false, true));

	document.querySelector(".spawn_option_checkbox").appendChild(option_checkbox_item);
}

document.addEventListener("DOMContentLoaded", function(event) {
	// Configure Tabs
	AddTab("props", "props", "images/tabs/chair.png", "images/tabs/chair-disabled.png");
	// AddTab("entities", "entities", "images/tabs/rocket.png", "images/tabs/rocket-disabled.png");
	AddTab("weapons", "weapons", "images/tabs/gun.png", "images/tabs/gun-disabled.png");
	AddTab("vehicles", "vehicles", "images/tabs/car.png", "images/tabs/car-disabled.png");
	AddTab("tools", "tools", "images/tabs/paint-spray.png", "images/tabs/paint-spray-disabled.png");
	AddTab("npcs", "npcs", "images/tabs/robot.png", "images/tabs/robot-disabled.png");

	TabClick(document.querySelectorAll(".tab")[0]);

	// Configure options - WORKAROUND FOR NOW
	AddOption("None", "");

	for (let i = 0; i < PatternList.length; i++) {
		AddOption(`Pattern #${i}`, `assets///nanos-world/Textures/Pattern/${PatternList[i]}`, `assets///nanos-world/Textures/Pattern/Thumbnails/${PatternList[i]}`);
	}

	SelectOption(document.querySelectorAll(".spawn_option_checkbox_item")[0]);

	// const tabs = document.querySelectorAll(".tab");

	// for (let i = 0; i < tabs.length; i++) {
	// 	const tab = tabs[i];

	// 	tab.addEventListener("click", e => TabClick(e.target));
	// 	tab.addEventListener("mouseenter", e => ItemHover("Tab: " + tab.querySelector(".tab_name").innerHTML, true));
	// 	tab.addEventListener("mouseleave", e => ItemHover(false, false));
	// }

	// const popup_close = document.querySelector("#popup_close");
	// popup_close.addEventListener("click", function(e) {
	// 	e.preventDefault();

	// 	const _popup_callback_event = popup_callback_event;

	// 	ClosePopUpPrompt();

	// 	Events.Call(_popup_callback_event, false);
	// });

	const popup_input = document.querySelector("#popup_input");
	popup_input.addEventListener("blur", (e) => {
		if (!popup_callback_event)
			return;

		const _popup_callback_event = popup_callback_event;
		ClosePopUpPrompt();
		Events.Call(_popup_callback_event, false);
	});

	const popup_form = document.querySelector("#popup_form");
	popup_form.addEventListener("submit", function(e) {
		e.preventDefault();

		const _popup_input_value = document.querySelector("#popup_input").value;
		const _popup_callback_event = popup_callback_event;

		ClosePopUpPrompt();

		Events.Call(_popup_callback_event, true, _popup_input_value);
	});
});

var popup_callback_event = null;

function ClosePopUpPrompt() {
	const popup_prompt = document.querySelector("#popup_prompt");
	popup_prompt.style.display = 'none';

	popup_callback_event = null;
}

function ShowPopUpPrompt(text, callback_event) {
	const popup_text = document.querySelector("#popup_text");
	popup_text.innerHTML = text;

	const popup_prompt = document.querySelector("#popup_prompt");
	popup_prompt.style.display = "block";

	const popup_input = document.querySelector("#popup_input");
	popup_input.value = "";
	popup_input.focus();

	popup_callback_event = callback_event;
}

function DisplayAsset(asset_pack, asset_id, asset_name, image) {
	if (!image) image = "images/nanosworld_empty.png";

	const spawn_item = document.createElement("span");
	spawn_item.classList.add("spawn_item");
	spawn_item.addEventListener('click', SpawnItemClick);
	spawn_item.addEventListener('mouseenter', e => ItemHover(e.target.dataset.asset_id, true, true));
	spawn_item.addEventListener('mouseleave', e => ItemHover(false, false, true));

	const spawn_item_image = document.createElement("span");
	spawn_item_image.classList.add("spawn_item_image");

	const spawn_item_name = document.createElement("span");
	spawn_item_name.classList.add("spawn_item_name");

	spawn_item.dataset.asset_pack = asset_pack;
	spawn_item.dataset.asset_id = asset_id;
	
	spawn_item_image.style["background-image"] = `url('${image}'), url('images/nanosworld_empty.png')`;
	spawn_item_name.innerHTML = asset_name;

	spawn_item.appendChild(spawn_item_image);
	spawn_item.appendChild(spawn_item_name);

	document.querySelector("#spawn_list").appendChild(spawn_item);
}

function AddAssetPack(asset_pack_name, data) {
	assets[asset_pack_name] = JSON.parse(data);

	RefreshAssets();
}

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.querySelector("#spawn_menu");

	if (is_visible)
		spawn_menu.style.display = "block";
	else
		spawn_menu.style.display = "none";
});

Events.Subscribe("AddAssetPack", AddAssetPack);
Events.Subscribe("ToggleVoice", ToggleVoice);
Events.Subscribe("AddNotification", AddNotification);
Events.Subscribe("UpdateWeaponAmmo", UpdateWeaponAmmo);
Events.Subscribe("UpdateHealth", UpdateHealth);
Events.Subscribe("ToggleScoreboard", ToggleScoreboard);
Events.Subscribe("UpdatePlayer", UpdatePlayer);
Events.Subscribe("ShowPopUpPrompt", ShowPopUpPrompt);
Events.Subscribe("ClosePopUpPrompt", ClosePopUpPrompt);


var PatternList = [
	"T_80s_Pattern.jpg",
	"T_Chochip_Pattern.jpg",
	"T_Cracks_Pattern.jpg",
	"T_Desert_Marpat_Pattern.jpg",
	"T_Hexagon_Glow_Pattern.jpg",
	"T_Hexagon_Pattern.jpg",
	"T_Ink_Pattern.jpg",
	"T_LeafSpray_Pattern.jpg",
	"T_Net01_Pattern.jpg",
	"T_Stripes_Pattern.jpg",
	"T_Urban_Marpat_Pattern.jpg",
	"T_W90_Pattern.jpg",
	"T_W90K_Pattern.jpg",
	"T_Wood_Marpat_Pattern.jpg",
	"T_Murica_Pattern.jpg",
	"T_Watermelon_Pattern.jpg",
	"T_Infernoo.jpg",
	"T_Pattern_001.jpg",
	"T_Pattern_002.jpg",
	"T_Pattern_003.jpg",
	"T_Pattern_004.jpg",
	"T_Pattern_005.jpg",
	"T_Pattern_006.jpg",
	"T_Pattern_007.jpg",
	"T_Pattern_008.jpg",
	"T_Pattern_009.jpg",
	"T_Pattern_010.jpg",
	"T_Pattern_011.jpg",
	"T_Pattern_012.jpg",
	"T_Pattern_013.jpg",
	"T_Pattern_014.jpg",
	"T_Pattern_015.jpg",
	"T_Pattern_016.jpg",
	"T_Pattern_017.jpg",
	"T_Pattern_018.jpg",
	"T_Pattern_019.jpg",
	"T_Pattern_020.jpg",
	"T_Pattern_021.jpg",
	"T_Pattern_022.jpg",
	"T_Pattern_023.jpg",
	"T_Pattern_024.jpg",
	"T_Pattern_025.jpg",
	"T_Pattern_026.jpg",
	"T_Pattern_027.jpg",
	"T_Pattern_028.jpg",
	"T_Pattern_029.jpg",
	"T_Pattern_030.jpg",
	"T_Pattern_031.jpg",
	"T_Pattern_032.jpg",
	"T_Pattern_033.jpg",
	"T_Pattern_034.jpg",
	"T_Pattern_035.jpg",
	"T_Pattern_036.jpg",
	"T_Pattern_037.jpg",
	"T_Pattern_038.jpg",
	"T_Pattern_039.jpg",
	"T_Pattern_040.jpg",
	"T_Pattern_041.jpg",
	"T_Pattern_042.jpg",
	"T_Pattern_043.jpg",
	"T_Pattern_044.jpg",
	"T_Pattern_045.jpg",
	"T_Pattern_046.jpg",
	"T_Pattern_047.jpg",
	"T_Pattern_048.jpg",
	"T_Pattern_049.jpg",
	"T_Pattern_050.jpg",
	"T_Pattern_051.jpg",
	"T_Pattern_052.jpg",
	"T_Pattern_053.jpg",
	"T_Pattern_054.jpg",
	"T_Pattern_055.jpg",
	"T_Pattern_056.jpg",
	"T_Pattern_057.jpg",
	"T_Pattern_058.jpg",
	"T_Pattern_059.jpg",
	"T_Pattern_060.jpg",
	"T_Pattern_061.jpg",
	"T_Pattern_062.jpg",
	"T_Pattern_063.jpg",
	"T_Pattern_064.jpg",
	"T_Pattern_065.jpg",
	"T_Pattern_066.jpg",
	"T_Pattern_067.jpg",
	"T_Pattern_068.jpg",
	"T_Pattern_069.jpg",
	"T_Pattern_070.jpg",
	"T_Pattern_071.jpg",
	"T_Pattern_072.jpg",
	"T_Pattern_073.jpg",
	"T_Pattern_074.jpg",
	"T_Pattern_075.jpg",
	"T_Pattern_076.jpg",
	"T_Pattern_077.jpg",
	"T_Pattern_078.jpg",
	"T_Pattern_079.jpg",
	"T_Pattern_080.jpg",
	"T_Pattern_081.jpg",
	"T_Pattern_082.jpg",
	"T_Pattern_083.jpg",
	"T_Pattern_084.jpg",
	"T_Pattern_085.jpg",
	"T_Pattern_086.jpg",
	"T_Pattern_087.jpg",
	"T_Pattern_088.jpg",
	"T_Pattern_089.jpg",
	"T_Pattern_090.jpg",
	"T_Pattern_091.jpg",
	"T_Pattern_092.jpg",
	"T_Pattern_093.jpg",
	"T_Pattern_094.jpg",
	"T_Pattern_095.jpg",
	"T_Pattern_096.jpg",
	"T_Pattern_097.jpg",
	"T_Pattern_098.jpg",
	"T_Pattern_099.jpg",
	"T_Pattern_100.jpg",
	"T_Pattern_101.jpg",
	"T_Pattern_102.jpg",
	"T_Pattern_103.jpg",
	"T_Pattern_104.jpg",
	"T_Pattern_105.jpg",
	"T_Pattern_106.jpg",
	"T_Pattern_107.jpg",
	"T_Pattern_108.jpg",
	"T_Pattern_109.jpg",
	"T_Pattern_110.jpg",
	"T_Pattern_111.jpg",
	"T_Pattern_112.jpg",
	"T_Pattern_113.jpg",
	"T_Pattern_114.jpg",
	"T_Pattern_115.jpg",
	"T_Pattern_116.jpg",
	"T_Pattern_117.jpg"
]