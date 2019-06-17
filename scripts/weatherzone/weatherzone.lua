function onLoad()
	weather = {
		Rain = {
			{
				name = "Off",
			},
			{
				name = "Light Rain",
				path = self.getChildren()[1].getChildren()[3].getChildren()[5],
				property = "activeInHierarchy",
				value_on = true,
				value_off = false,
			},
			{
				name = "Medium Rain",
				path = self.getChildren()[1].getChildren()[3].getChildren()[6],
				property = "activeInHierarchy",
				value_on = true,
				value_off = false,
			},
			{
				name = "Heavy Rain",
				path = self.getChildren()[1].getChildren()[3].getChildren()[7],
				property = "activeInHierarchy",
				value_on = true,
				value_off = false,
			},
			{
				name = "Torrential Rain",
				path = self.getChildren()[1].getChildren()[3].getChildren()[8],
				property = "activeInHierarchy",
				value_on = true,
				value_off = false,
			},
		}
	}
	doTest()
end

function doTest()
	local rain = self.getChildren()[1].getChildren()[3].getChildren()[7].getVars()
	log(rain)
	log("Logging debug ===")
	log(rain)
	log("====")
end