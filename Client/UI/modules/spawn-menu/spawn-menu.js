let current_category = "";
let current_tab = "";
let observer = null;

let spawn_menu_items = {};
let tabs = {};


function SpawnItemClick(e) {
	const item_id = e.target.dataset.item_id;
	Events.Call("SpawnItem", current_tab, item_id);
}

function ItemHover(label, enter, is_spawn_item) {
	const label_element = document.getElementById("label");

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

	// TODO fix workaround for patterns
	if (current_tab == "weapons")
		ToggleOptions(false);
	else if (new_tab == "weapons")
		ToggleOptions(true);

	current_tab = new_tab;

	// Clears Categories List
	document.getElementById("spawn_categories").innerHTML = "";

	if (tabs[current_tab]) {
		for (let category in tabs[current_tab].categories) {
			const category_data = tabs[current_tab].categories[category];
			DisplayCategory(category_data.id, category_data.label, category_data.image);
		}
	}

	// Adds "all" category
	DisplayCategory("all", "All", "modules/spawn-menu/images/categories/infinity.webp", "modules/spawn-menu/images/categories/infinity-disabled.webp");

	// Forces click on first category
	CategoryClick(document.querySelectorAll(".spawn_category")[0]);

	const old_tab_active = document.querySelector(".tab.active");
	if (old_tab_active)
		old_tab_active.classList.remove("active");

	tab_element.classList.add("active");
}

function CategoryClick(category_item) {
	const new_category = category_item.dataset.category_id;

	current_category = new_category;

	RefreshSpawnMenu();

	const old_category_active = document.querySelector(".spawn_category.active");
	if (old_category_active)
		old_category_active.classList.remove("active");

	category_item.classList.add("active");

	Events.Call("ClickSound");
}

function AddCategory(tab_id, id, label, image) {
	if (!tabs[tab_id])
		tabs[tab_id] = { categories: [] };

	tabs[tab_id].categories.push({
		id: id,
		label: label,
		image: `modules/spawn-menu/images/${image}`,
	});
}

function DisplayCategory(id, name, image) {
	const category = document.createElement("span");
	category.classList.add("spawn_category");
	category.addEventListener("click", e => CategoryClick(e.target));
	category.addEventListener("mouseenter", e => ItemHover("Category: " + e.target.dataset.category_name, true));
	category.addEventListener("mouseleave", e => ItemHover(false, false));

	category.dataset.category_id = id;
	category.dataset.category_name = name;
	category.dataset.image = image;

	category.style["background-image"] = `url('${image}')`;

	document.getElementById("spawn_categories").appendChild(category);
}

function AddTab(id, name, image) {
	const tab = document.createElement("span");
	tab.classList.add("tab");
	tab.addEventListener("click", e => TabClick(e.target));
	tab.addEventListener("mouseenter", e => ItemHover("Tab: " + e.target.dataset.tab_name, true));
	tab.addEventListener("mouseleave", e => ItemHover(false, false));

	const tab_image = document.createElement("img");
	tab_image.src = `modules/spawn-menu/images/${image}`;

	const tab_name = document.createElement("span");
	tab_name.classList.add("tab_name");
	tab_name.innerHTML = name;

	tab.appendChild(tab_image);
	tab.appendChild(tab_name);

	tab.dataset.tab_id = id;
	tab.dataset.tab_name = name;
	tab.dataset.image = `modules/spawn-menu/images/${image}`;

	document.getElementById("tabs").appendChild(tab);
}

function RefreshSpawnMenu() {
	// Clears Spawn List
	document.getElementById("spawn_list").innerHTML = "";

	// Loads all items
	for (let item_id in spawn_menu_items[current_tab]) {
		const item = spawn_menu_items[current_tab][item_id];

		// Filter category
		if (current_category != "all" && item.category != current_category)
			continue;

		AddItem(item.id, item.name, item.image);
	}

	observer.observe();
}

function ToggleOptions(enable) {
	const spawn_list = document.getElementById("spawn_list");
	const spawn_options = document.getElementById("spawn_options");

	if (enable) {
		spawn_options.style.display = "block";
		spawn_list.style.right = "200px";
	} else {
		spawn_options.style.display = "none";
		spawn_list.style.right = "0";
	}
}

function SelectOption(element, force_no_event) {
	const texture_path = element.dataset.texture;

	const old_option_selected = document.querySelector(".spawn_option_checkbox_item.selected");
	if (old_option_selected)
		old_option_selected.classList.remove("selected");

	element.classList.add("selected");

	if (!force_no_event)
		Events.Call("SelectOption", texture_path);
}

function AddOption(name, texture, texture_thumbnail) {
	// Todo this is completely bad, it's just an workaround for now, we must make it generic

	const option_checkbox_item = document.createElement("span");
	option_checkbox_item.classList.add("spawn_option_checkbox_item", "lozad");
	option_checkbox_item.setAttribute("data-background-image", `${texture_thumbnail || texture}, modules/spawn-menu/images/empty-set.webp`);

	option_checkbox_item.dataset.name = name;
	option_checkbox_item.dataset.texture = texture;

	option_checkbox_item.addEventListener("click", e => SelectOption(e.target));
	option_checkbox_item.addEventListener("mouseenter", e => ItemHover("Pattern: " + e.target.dataset.name, true, true));
	option_checkbox_item.addEventListener("mouseleave", e => ItemHover(false, false, true));

	document.querySelector(".spawn_option_checkbox").appendChild(option_checkbox_item);
}

document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the spawn menu
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="spawn_menu">
			<div id="label">Label Description</div>
			<div id="tabs">
				<!-- <span id="props" class="tab active">
					<img src="./images/tabs/chair.png"/>
					<span class="tab_name">props</span>
				</span> -->
			</div>
			<div id="spawn_categories">
				<!-- <span class="spawn_category active" style="background-image: url('./images/categories/tools.webp')"></span> -->
			</div>
			<div id="spawn_list">
				<!-- <span class="spawn_item">
					<span class="spawn_item_image" style="background-image: url('./images/nanosworld_empty.webp')"></span>
					<span class="spawn_item_name">Name</span>
				</span> -->
			</div>
			<div id="spawn_options">
				<span class="spawn_option">
					<span class="spawn_option_label">Pattern</span>
					<span class="spawn_option_checkbox">
						<!-- <span class="spawn_option_checkbox_item" style="background-image: url('T_Stripes_Pattern.jpg')"></span> -->
					</span>
				</span>
			</div>
		</div>
	`);

	// Configure options - WORKAROUND FOR NOW
	AddOption("None", "");

	for (let i = 0; i < PatternList.length; i++) {
		AddOption(`Pattern #${i}`, `assets://nanos-world/Textures/Pattern/${PatternList[i]}`, `assets://nanos-world/Textures/Pattern/Thumbnails/${PatternList[i]}`);
	}

	// Selects the first option by default
	SelectOption(document.querySelectorAll(".spawn_option_checkbox_item")[0], true);

	// Loads Lozad (Lazy Loader)
	observer = lozad();
	observer.observe();
});

function AddItem(item_id, item_name, image) {
	if (!image) image = "modules/spawn-menu/images/nanosworld_empty.webp";

	const spawn_item = document.createElement("span");
	spawn_item.classList.add("spawn_item");
	spawn_item.addEventListener("click", SpawnItemClick);
	spawn_item.addEventListener("mouseenter", e => ItemHover(e.target.dataset.item_id, true, true));
	spawn_item.addEventListener("mouseleave", e => ItemHover(false, false, true));
	spawn_item.dataset.item_id = item_id;

	const spawn_item_image = document.createElement("span");
	spawn_item_image.classList.add("spawn_item_image", "lozad");
	spawn_item_image.setAttribute("data-background-image", `${image}, modules/spawn-menu/images/nanosworld_empty.webp`);

	const spawn_item_name = document.createElement("span");
	spawn_item_name.classList.add("spawn_item_name");
	spawn_item_name.innerHTML = item_name;

	spawn_item.appendChild(spawn_item_image);
	spawn_item.appendChild(spawn_item_name);

	document.getElementById("spawn_list").appendChild(spawn_item);
}

function SetSpawnMenuItems(items) {
	spawn_menu_items = items;

	RefreshSpawnMenu();
}

function AddSpawnMenuItem(tab_id, item) {
	spawn_menu_items[tab_id].push(item);

	RefreshSpawnMenu();
}

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.getElementById("spawn_menu");

	if (is_visible) {
		// If there's no tab selected, select the first one
		if (!current_tab)
			TabClick(document.querySelectorAll(".tab")[0]);

		spawn_menu.style.display = "block";
	}
	else
		spawn_menu.style.display = "none";
});


Events.Subscribe("SetSpawnMenuItems", SetSpawnMenuItems);
Events.Subscribe("AddSpawnMenuItem", AddSpawnMenuItem);
Events.Subscribe("AddTab", AddTab);
Events.Subscribe("AddCategory", AddCategory);


// TODO fix pattern workaround, move to Lua?
const PatternList = [
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