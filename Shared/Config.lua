

-- List of Character Meshes
CHARACTER_MESHES = {
	["nanos-world::SK_ClassicMale"] = {
		is_male = true,
		name = "Classic Male",
		image = "assets://nanos-world/Thumbnails/SK_ClassicMale.jpg",
	},
	["nanos-world::SK_PostApocalyptic"] = {
		is_male = true,
		name = "Post Apocalyptic",
		image = "assets://nanos-world/Thumbnails/SK_PostApocalyptic.jpg",
	},
	["nanos-world::SK_Mannequin"] = {
		is_male = true,
		name = "Mannequin",
		image = "assets://nanos-world/Thumbnails/SK_Mannequin.jpg",
	},
	["nanos-world::SK_Mannequin_Female"] = {
		is_male = false,
		name = "Mannequin Female",
		image = "assets://nanos-world/Thumbnails/SK_Mannequin_Female.jpg",
	},
	["nanos-world::SK_Male"] = {
		is_male = true,
		name = "Male",
		image = "assets://nanos-world/Thumbnails/SK_Male.jpg",
		skeletal_meshes = {
			["shirt"] = {
				"nanos-world::SK_Underwear",
				"nanos-world::SK_Shirt",
			},
			["pants"] = {
				"nanos-world::SK_Pants",
				"",
			},
			["shoes"] = {
				"nanos-world::SK_Shoes_01",
				"nanos-world::SK_Shoes_02",
			},
			["tie"] = {
				"nanos-world::SK_Tie",
				""
			}
		},
		static_meshes = {
			["hair"] = {
				socket = "hair_male",
				meshes = {
					"",
					"nanos-world::SM_Hair_Long",
					"nanos-world::SM_Hair_Short"
				}
			},
			["beard"] = {
				socket = "beard",
				meshes = {
					"",
					"nanos-world::SM_Beard_Extra",
					"nanos-world::SM_Beard_Middle",
					"nanos-world::SM_Beard_Mustache_01",
					"nanos-world::SM_Beard_Mustache_02",
					"nanos-world::SM_Beard_Side"
				}
			},
			["eye_left"] = {
				socket = "eye_left",
				meshes = {
					"nanos-world::SM_Eye"
				}
			},
			["eye_right"] = {
				socket = "eye_right",
				meshes = {
					"nanos-world::SM_Eye"
				}
			}
		},
		materials_parameters_color = {
			{
				parameter = "Tint",
				slot = "",
				values = {
					Color(1.000000, 1.000000, 1.000000),
					Color(1.000000, 0.926933, 0.820785),
					Color(0.984375, 0.854302, 0.661377),
					Color(1.000000, 0.866979, 0.785255),
					Color(0.890625, 0.768996, 0.658135),
					Color(0.880208, 0.706081, 0.588818),
					Color(0.526042, 0.340051, 0.221689),
					Color(0.244792, 0.185846, 0.151720),
					Color(0.791667, 0.573959, 0.428820),
					Color(0.947917, 0.655642, 0.399902),
					Color(0.583333, 0.406594, 0.261284),
					Color(0.645833, 0.465268, 0.360730),
					Color(1.000000, 0.917535, 0.739583),
					Color(0.932292, 0.825388, 0.670085),
					Color(0.817708, 0.710384, 0.549398),
					Color(0.765625, 0.620475, 0.454590),
					Color(0.050000, 0.050000, 0.080000),
				}
			},
			{
				parameter = "HairTint",
				slot = "hair",
				values = {
					Color(0.067708, 0.030797, 0.001471),
					Color(0.983483, 1.000000, 0.166667),
					Color(0.010000, 0.010000, 0.010000),
					Color(1.000000, 0.129006, 0.000000),
				}
			},
			{
				parameter = "HairTint",
				slot = "beard",
				values = {
					Color(0.067708, 0.030797, 0.001471),
					Color(0.983483, 1.000000, 0.166667),
					Color(0.010000, 0.010000, 0.010000),
					Color(1.000000, 0.129006, 0.000000),
				}
			}
		},
		morph_targets = {
			"nose1",
			"nose2",
			"brows",
			"mouth",
			"fat",
			"nose3",
			"chin",
			"face",
			"nose4",
			"skinny",
			"jaw",
			"brows2",
			"angry",
			-- "smirk",
			-- "smirk2",
			-- "smirk3",
			"smile",
			"nose6",
			"jaw_forward",
			"lips",
			"lips2",
			"mouth_wide",
			"eyes1",
			"eyes2",
			"eyes3",
			"eyes4",
			"eyes_retraction",
			"lips3",
			"eyes5",
			"nose7",
			"forehead",
			"bodyfat",
		}
	},
	["nanos-world::SK_Female"] = {
		is_male = false,
		name = "Female",
		image = "assets://nanos-world/Thumbnails/SK_Female.jpg",
		skeletal_meshes = {
			["shoes"] = {
				"nanos-world::SK_Sneakers",
				""
			},
			["clothes"] = "nanos-world::SK_CasualSet"
		},
		static_meshes = {
			["hair"] = {
				socket = "hair_female",
				meshes = {
					"",
					"nanos-world::SM_Hair_Kwang"
				}
			},
			["eye_left"] = {
				socket = "eye_left",
				meshes = {
					"nanos-world::SM_Eye"
				}
			},
			["eye_right"] = {
				socket = "eye_right",
				meshes = {
					"nanos-world::SM_Eye"
				}
			}
		},
		materials = {
			{
				slot = "clothes",
				index = -1,
				values = {
					"nanos-world::MI_CasualSet_01",
					"nanos-world::MI_CasualSet_02",
					"nanos-world::MI_CasualSet_03",
					"nanos-world::MI_CasualSet_04",
					"nanos-world::MI_CasualSet_05",
					"nanos-world::MI_CasualSet_06",
				}
			}
		},
		materials_parameters_color = {
			{
				parameter = "Tint",
				slot = "",
				values = {
					Color(1.000000, 1.000000, 1.000000),
					Color(1.000000, 0.926933, 0.820785),
					Color(0.984375, 0.854302, 0.661377),
					Color(1.000000, 0.866979, 0.785255),
					Color(0.890625, 0.768996, 0.658135),
					Color(0.880208, 0.706081, 0.588818),
					Color(0.526042, 0.340051, 0.221689),
					Color(0.244792, 0.185846, 0.151720),
					Color(0.791667, 0.573959, 0.428820),
					Color(0.947917, 0.655642, 0.399902),
					Color(0.583333, 0.406594, 0.261284),
					Color(0.645833, 0.465268, 0.360730),
					Color(1.000000, 0.917535, 0.739583),
					Color(0.932292, 0.825388, 0.670085),
					Color(0.817708, 0.710384, 0.549398),
					Color(0.765625, 0.620475, 0.454590),
					Color(0.050000, 0.050000, 0.080000),
				}
			},
			{
				parameter = "TipColor",
				slot = "hair",
				values = {
					Color(0.067708, 0.030797, 0.001471),
					Color(0.983483, 1.000000, 0.166667),
					Color(0.010000, 0.010000, 0.010000),
					Color(1.000000, 0.129006, 0.000000),
				}
			}
		},
		morph_targets = {
			"Shape",
			-- "open1",
			-- "open2",
			-- "open3",
			-- "open4",
			-- "smile",
			"belly",
			-- "breast",
			-- "breast2",
			"hips",
			-- "fatold",
			"fat",
			-- "jaw_forward",
			-- "head1",
			"head2",
			"nose1",
			-- "head3",
			-- "brows",
			-- "smirk",
			-- "anger",
			-- "eye1",
			-- "eyes2",
			-- "eyes3",
			-- "eyes4",
			"eyes5",
			-- "monolid",
			"nose_wide",
			"nose4",
			"nose3",
			"nose2",
			-- "nose1_copy1",
			-- "forehead",
			"head4",
			-- "brows2",
			-- "lip_l",
			-- "lip_u",
			"age",
			-- "lids",
			"lips_pouty",
			"lips_wide",
			-- "cupids",
			"head5",
			"head6",
			"lips",
			-- "eyes_close2",
			-- "eyes_close2_copy1",
			-- "eyes6",
			-- "eyes_close",
			"breast_small",
			"glutes",
			-- "breast3",
			-- "breast4old",
			"breast4",
			-- "eyes_retraction",
			"eyes_up",
			"eyes_wideset",
			"eyes_deep",
			-- "eyes_deep2",
			"jaw_skinny",
			"chin_up",
			-- "lipl_big",
			-- "lipu_big",
			-- "au2",
			-- "au2v2",
			-- "au1",
			-- "au1v2",
			-- "au1l",
			-- "au3v3",
			-- "au4",
			-- "au4v2",
			-- "au4v4",
			-- "eyes_shape",
			"nose_shape",
			-- "nose_end",
			-- "eyes_hooded",
			-- "eyes_hooded2",
			-- "lines",
			-- "mouth_open",
			-- "eyes_angle",
			-- "eyes_angle2",
			-- "cheeks_skinny",
			-- "mouth_up",
			-- "mouth_line",
			-- "eyes_almond",
			-- "eyes_almond2",
			-- "neweyes",
			-- "neweyes2",
			-- "neweyes3",
			-- "neweyes4",
			-- "nosep",
			-- "nosebulbous",
			-- "nosewide",
			-- "smile_copy1",
			-- "smile2",
			-- "lipsshape",
			-- "head6_copy1",
			"head7",
			-- "brows3",
			"head8",
			"head9",
			-- "noselong",
			-- "nose7",
			-- "chin3",
		}
	},
	["nanos-world::SK_Adventure_01_Full_02"] = {
		is_male = false,
		name = "Adventure Female 01",
		image = "assets://nanos-world/Thumbnails/SK_Adventure_01.jpg",
		speak_animation = "nanos-world::A_Adventure_Mouth_Talk",
		morph_targets_force = {
			["Close_Mouth"] = 1
		},
		materials = {
			{
				slot = "",
				index = 0,
				values = {
					"nanos-world::MI_Adventure_01_01",
					"nanos-world::MI_Adventure_01_02",
					"nanos-world::MI_Adventure_01_03",
				}
			}
		}
	},
	["nanos-world::SK_Adventure_02_Full_03"] = {
		is_male = true,
		name = "Adventure Male 02",
		image = "assets://nanos-world/Thumbnails/SK_Adventure_02.jpg",
		speak_animation = "nanos-world::A_Adventure_Mouth_Talk",
		morph_targets_force = {
			["Close_Mouth"] = 1
		},
		materials = {
			{
				slot = "",
				index = 0,
				values = {
					"nanos-world::MI_Adventure_02_01",
					"nanos-world::MI_Adventure_02_02",
					"nanos-world::MI_Adventure_02_03",
				}
			}
		}
	},
	["nanos-world::SK_Adventure_03_Full_02"] = {
		is_male = false,
		name = "Adventure Female 03",
		image = "assets://nanos-world/Thumbnails/SK_Adventure_03.jpg",
		speak_animation = "nanos-world::A_Adventure_Mouth_Talk",
		morph_targets_force = {
			["Close_Mouth"] = 1
		},
		materials = {
			{
				slot = "",
				index = 0,
				values = {
					"nanos-world::MI_Adventure_03_01",
					"nanos-world::MI_Adventure_03_02",
					"nanos-world::MI_Adventure_03_03",
				}
			}
		}
	},
	["nanos-world::SK_Adventure_04_Full_02"] = {
		is_male = true,
		name = "Adventure Male 04",
		image = "assets://nanos-world/Thumbnails/SK_Adventure_04.jpg",
		speak_animation = "nanos-world::A_Adventure_Mouth_Talk",
		morph_targets_force = {
			["Close_Mouth"] = 1
		},
		materials = {
			{
				slot = "",
				index = 0,
				values = {
					"nanos-world::MI_Adventure_04_01",
					"nanos-world::MI_Adventure_04_02",
					"nanos-world::MI_Adventure_04_03",
				}
			}
		}
	},
	["nanos-world::SK_Adventure_05_Full_02"] = {
		is_male = true,
		name = "Adventure Male 05",
		image = "assets://nanos-world/Thumbnails/SK_Adventure_05.jpg",
		speak_animation = "nanos-world::A_Adventure_Mouth_Talk",
		morph_targets_force = {
			["Close_Mouth"] = 1
		},
		materials = {
			{
				slot = "",
				index = 0,
				values = {
					"nanos-world::MI_Adventure_05_01",
					"nanos-world::MI_Adventure_05_02",
					"nanos-world::MI_Adventure_05_03",
					"nanos-world::MI_Adventure_05_NoTattoo_01",
					"nanos-world::MI_Adventure_05_NoTattoo_02",
					"nanos-world::MI_Adventure_05_NoTattoo_03",
				}
			}
		}
	}
}

-- List of Death Male voices
MALE_DEATH_SOUNDS = {
	"nanos-world::A_Male_01_Death",
	"nanos-world::A_Male_02_Death",
	"nanos-world::A_Male_03_Death",
	"nanos-world::A_Male_04_Death",
	"nanos-world::A_Male_05_Death",
	"nanos-world::A_Male_06_Death",
	"nanos-world::A_Wilhelm_Scream"
}

-- List of Pain Male voices
MALE_PAIN_SOUNDS = {
	"nanos-world::A_Male_01_Pain",
	"nanos-world::A_Male_02_Pain",
	"nanos-world::A_Male_03_Pain",
	"nanos-world::A_Male_04_Pain",
	"nanos-world::A_Male_05_Pain",
	"nanos-world::A_Male_06_Pain",
	"nanos-world::A_Male_07_Pain",
	"nanos-world::A_Male_06_Pain"
}

-- List of Death Female voices
FEMALE_DEATH_SOUNDS = {
	"nanos-world::A_Female_01_Death",
	"nanos-world::A_Female_02_Death",
	"nanos-world::A_Female_03_Death",
	"nanos-world::A_Female_04_Death",
	"nanos-world::A_Female_05_Death"
}

-- List of Pain Female voices
FEMALE_PAIN_SOUNDS = {
	"nanos-world::A_Female_01_Pain",
	"nanos-world::A_Female_02_Pain",
	"nanos-world::A_Female_03_Pain",
	"nanos-world::A_Female_04_Pain",
	"nanos-world::A_Female_05_Pain",
	"nanos-world::A_Female_06_Pain",
	"nanos-world::A_Female_07_Pain",
	"nanos-world::A_Female_06_Pain"
}