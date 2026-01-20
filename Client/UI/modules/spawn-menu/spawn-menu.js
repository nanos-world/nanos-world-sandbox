const SpawnMenu = {
	is_visible: false,

	observer_tabs: {},

	// Aux for debouncing
	search_debounce: {
		timeout: null,
		Run: function(callback, delay) {
			clearTimeout(this.timeout);
			this.timeout = setTimeout(callback, delay);
		}
	}
}

// TODO Close button
document.addEventListener("DOMContentLoaded", function(event) {
	// Inserts the spawn menu
	const body = document.querySelector(`body`);

	body.insertAdjacentHTML("afterbegin", `
		<div id="spawn_menu">
			<div id="label">Label Description</div>
			<div id="message"></div>
			<div id="search">
				<input type="search" id="search_input" placeholder="search..." spellcheck="false" />
			</div>
			<div id="tabs">
				<!-- <span id="props" class="tab active">
					<img src="./images/tabs/chair.webp"/>
					<span class="tab_name">props</span>
				</span> -->
			</div>
			<div id="spawn_menu_content">
			 	<!-- <div id="spawn_menu_content_tab_props" class="spawn_menu_content_tab">
					<div class="spawn_menu_categories">
						<img class="spawn_category active" loading="lazy" src="./images/categories/tools.webp"></img>
					</div>
					<div class="spawn_menu_list">
						<span class="spawn_menu_content_category" id="spawn_menu_content_category_props_furniture">
							<span class="spawn_menu_divider">Furniture</span>
							<span class="spawn_item">
								<img class="spawn_item_image" loading="lazy" src="./images/nanosworld_empty.webp"></img>
								<span class="spawn_item_name">Name</span>
							</span>
						</span>
					</div>
				</div> -->
			</div>
		</div>
	`);

	const search_input = document.getElementById("search_input");
	search_input.addEventListener("input", function(e) {
		SpawnMenu.search_debounce.Run(() => SpawnMenu.OnSearch(e.target.value), 150);
	});
});

SpawnMenu.OnSearch = function(value) {
	// Gets current active tab
	const active_tab = document.querySelector(".tab.active");
	if (!active_tab) return;

	// Gets current content tab items
	const spawn_menu_content_tab = document.getElementById(`spawn_menu_content_tab_${active_tab.dataset.tab_id}`);
	const spawn_menu_items = spawn_menu_content_tab.querySelectorAll(".spawn_item");

	// Normalize search value
	const search_value = value.toLowerCase().trim();

	if (value && value.length > 0) {
		let found_items = 0;

		for (const item of spawn_menu_items) {
			// Searches in name and id
			const item_name = item.dataset.item_name.toLowerCase();
			const item_id = item.dataset.item_id.toLowerCase();

			// Marks as visible if matches
			if (item_name.includes(search_value) || item_id.includes(search_value)) {
				found_items++;
				item.classList.add("spawn_item_visible");
			} else {
				item.classList.remove("spawn_item_visible");
			}
		}

		// No items found
		document.getElementById("message").textContent = found_items === 0 ? "No results found." : "";

	} else {
		// Marks all as visible
		for (const item of spawn_menu_items) {
			item.classList.add("spawn_item_visible");
		}

		document.getElementById("message").textContent = "";
	}

	Events.Call("ClickSound");
}

SpawnMenu.SpawnItemClick = function(e) {
	const item_id = e.target.dataset.item_id;
	const tab_id = e.target.dataset.tab_id;

	Events.Call("SpawnItem", tab_id, item_id);
}

SpawnMenu.ItemHover = function(label, enter, is_spawn_item) {
	const label_element = document.getElementById("label");

	if (enter) {
		label_element.style.display = "block";
		label_element.textContent = label;
		Events.Call("HoverSound", is_spawn_item ? 1 : 0.9);
	} else {
		label_element.style.display = "none";
	}
}

SpawnMenu.TabClick = function(tab_element) {
	const new_tab = tab_element.dataset.tab_id;

	// Clear the search
	document.getElementById("search_input").value = "";
	SpawnMenu.OnSearch("");

	// Hides previous tab content
	const previous_tab_content = document.querySelectorAll(".spawn_menu_content_tab");
	previous_tab_content.forEach(tab_content => tab_content.style.display = "none");

	// Shows new tab content
	const new_tab_content = document.getElementById(`spawn_menu_content_tab_${new_tab}`);
	if (new_tab_content)
		new_tab_content.style.display = "block";

	const previous_tab_active = document.querySelector(".tab.active");
	if (previous_tab_active)
		previous_tab_active.classList.remove("active");

	tab_element.classList.add("active");

	Events.Call("ClickSound");
}

SpawnMenu.CategoryClick = function(category_item) {
	const category_id = category_item.dataset.category_id;
	const tab_id = category_item.dataset.tab_id;

	// Scrolls to divider
	const spawn_menu_content_category = document.getElementById(`spawn_menu_content_category_${tab_id}_${category_id}`);
	spawn_menu_content_category.scrollIntoView({ behavior: "smooth", block: "start" });

	Events.Call("ClickSound");
}

SpawnMenu.AddCategory = function(tab_id, id, label, image) {
	const spawn_menu_content_tab = document.getElementById(`spawn_menu_content_tab_${tab_id}`);
	const spawn_menu_list = spawn_menu_content_tab.querySelector(".spawn_menu_list");
	const spawn_menu_categories = spawn_menu_content_tab.querySelector(".spawn_menu_categories");

	const category = document.createElement("img");
	category.classList.add("spawn_category");
	category.id = `spawn_menu_category_${tab_id}_${id}`;
	category.addEventListener("click", e => SpawnMenu.CategoryClick(e.target));
	category.addEventListener("mouseenter", e => SpawnMenu.ItemHover("Category: " + e.target.dataset.category_name, true));
	category.addEventListener("mouseleave", e => SpawnMenu.ItemHover(false, false));

	category.dataset.category_id = id;
	category.dataset.tab_id = tab_id;
	category.dataset.category_name = label;

	category.src = image;
	category.loading = "lazy";

	spawn_menu_categories.appendChild(category);

	// Add category container
	const spawn_menu_content_category = document.createElement("div");
	spawn_menu_content_category.classList.add("spawn_menu_content_category");
	spawn_menu_content_category.id = `spawn_menu_content_category_${tab_id}_${id}`;
	spawn_menu_content_category.dataset.category = category;
	spawn_menu_content_category.dataset.category_id = id;
	spawn_menu_content_category.dataset.tab_id = tab_id;

	// Add divisor
	const divisor = document.createElement("div");
	divisor.classList.add("spawn_menu_divider");
	divisor.textContent = label.toLowerCase();
	spawn_menu_content_category.appendChild(divisor);

	// Add content container
	const spawn_menu_items = document.createElement("div");
	spawn_menu_items.classList.add("spawn_menu_items");
	spawn_menu_content_category.appendChild(spawn_menu_items);

	spawn_menu_list.appendChild(spawn_menu_content_category);

	// Adds the category to the tab observer
	SpawnMenu.observer_tabs[tab_id].observe(spawn_menu_content_category);
}

SpawnMenu.AddTab = function(id, name, image) {
	// Adds tab to header
	const tab = document.createElement("span");
	tab.classList.add("tab");
	tab.addEventListener("click", e => SpawnMenu.TabClick(e.target));
	tab.addEventListener("mouseenter", e => SpawnMenu.ItemHover("Tab: " + e.target.dataset.tab_name, true));
	tab.addEventListener("mouseleave", e => SpawnMenu.ItemHover(false, false));

	const tab_image = document.createElement("img");
	tab_image.src = image;
	tab_image.loading = "lazy";

	const tab_name = document.createElement("span");
	tab_name.classList.add("tab_name");
	tab_name.textContent = name;

	tab.appendChild(tab_image);
	tab.appendChild(tab_name);

	tab.dataset.tab_id = id;
	tab.dataset.tab_name = name;

	document.getElementById("tabs").appendChild(tab);

	// Adds tab content
	const spawn_menu_content = document.getElementById("spawn_menu_content");

	const spawn_menu_content_tab = document.createElement("div");
	spawn_menu_content_tab.classList.add("spawn_menu_content_tab");
	spawn_menu_content_tab.id = `spawn_menu_content_tab_${id}`;

	const spawn_menu_categories = document.createElement("div");
	spawn_menu_categories.classList.add("spawn_menu_categories");
	spawn_menu_content_tab.appendChild(spawn_menu_categories);

	const spawn_menu_list = document.createElement("div");
	spawn_menu_list.classList.add("spawn_menu_list");
	spawn_menu_content_tab.appendChild(spawn_menu_list);

	spawn_menu_content.appendChild(spawn_menu_content_tab);

	// Creates observer for the tab
	SpawnMenu.observer_tabs[id] = new IntersectionObserver(function(entries, observer) {
		entries.forEach(entry => {
			// Gets the category element
			const category_id = entry.target.dataset.category_id;
			const tab_id = entry.target.dataset.tab_id;
			const category = document.getElementById(`spawn_menu_category_${tab_id}_${category_id}`);

			// Adds active to the category if is intersecting
			if (entry.isIntersecting)
				category.classList.add('active');
			else
				category.classList.remove('active');
		});
	}, {
		root: spawn_menu_list,
		threshold: 0.1,
		delay: 100
	})
}

SpawnMenu.AddItem = function(tab_id, category_id, item) {
	const image = item.image ? item.image : "modules/spawn-menu/images/nanosworld_empty.webp";

	const spawn_item = document.createElement("span");
	spawn_item.classList.add("spawn_item", "spawn_item_visible");
	spawn_item.addEventListener("click", SpawnMenu.SpawnItemClick);
	spawn_item.addEventListener("mouseenter", e => SpawnMenu.ItemHover(e.target.dataset.item_id, true, true));
	spawn_item.addEventListener("mouseleave", e => SpawnMenu.ItemHover(false, false, true));
	spawn_item.dataset.item_id = item.id;
	spawn_item.dataset.item_name = item.name;
	spawn_item.dataset.category_id = category_id;
	spawn_item.dataset.tab_id = tab_id;

	const spawn_item_image = document.createElement("img");
	spawn_item_image.classList.add("spawn_item_image");
	spawn_item_image.loading = "lazy";
	spawn_item_image.src = image;

	const spawn_item_name = document.createElement("span");
	spawn_item_name.classList.add("spawn_item_name");
	spawn_item_name.textContent = item.name;

	spawn_item.appendChild(spawn_item_image);
	spawn_item.appendChild(spawn_item_name);

	const spawn_menu_content_category = document.getElementById(`spawn_menu_content_category_${tab_id}_${category_id}`);
	const spawn_menu_items = spawn_menu_content_category.querySelector(".spawn_menu_items");
	spawn_menu_items.appendChild(spawn_item);
}

SpawnMenu.SetSpawnMenuItems = function(items) {
	// For each tab, iterates all categories and add all items from it
	for (const tab in items) {
		for (const category in items[tab]) {
			items[tab][category].forEach(item => {
				SpawnMenu.AddItem(tab, category, item);
			});
		}
	}

	// Clicks on the first tab
	SpawnMenu.TabClick(document.querySelectorAll(".tab")[0]);
}

SpawnMenu.AddSpawnMenuItem = function(tab_id, category_id, item) {
	SpawnMenu.AddItem(tab_id, category_id, item);
}

Events.Subscribe("ToggleSpawnMenuVisibility", function(is_visible) {
	const spawn_menu = document.getElementById("spawn_menu");

	SpawnMenu.is_visible = is_visible;

	if (is_visible)
		spawn_menu.style.display = "block";
	else
		spawn_menu.style.display = "none";

	// Show/Hide the Tutorials
	if (Tutorials.has_tutorial)
		Tutorials.SetVisibility(!is_visible);
});


Events.Subscribe("SetSpawnMenuItems", SpawnMenu.SetSpawnMenuItems);
Events.Subscribe("AddSpawnMenuItem", SpawnMenu.AddSpawnMenuItem);
Events.Subscribe("AddTab", SpawnMenu.AddTab);
Events.Subscribe("AddCategory", SpawnMenu.AddCategory);