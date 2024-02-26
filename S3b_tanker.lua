mission = 
{
    ["coalition"] = 
    {
        ["blue"] = 
        {
            ["bullseye"] = 
            {
                ["y"] = 617414,
                ["x"] = -291014,
            }, -- end of ["bullseye"]
            ["nav_points"] = 
            {
            }, -- end of ["nav_points"]
            ["name"] = "blue",
            ["country"] = 
            {
                [1] = 
                {
                    ["id"] = 80,
                    ["name"] = "CJTF Blue",
                    ["plane"] = 
                    {
                        ["group"] = 
                        {
                            [1] = 
                            {
                                ["modulation"] = 0,
                                ["tasks"] = 
                                {
                                }, -- end of ["tasks"]
                                ["radioSet"] = true,
                                ["task"] = "Refueling",
                                ["uncontrolled"] = false,
                                ["route"] = 
                                {
                                    ["points"] = 
                                    {
                                        [1] = 
                                        {
                                            ["alt"] = 4876.8,
                                            ["action"] = "Turning Point",
                                            ["alt_type"] = "BARO",
                                            ["speed"] = 195.21709789325,
                                            ["task"] = 
                                            {
                                                ["id"] = "ComboTask",
                                                ["params"] = 
                                                {
                                                    ["tasks"] = 
                                                    {
                                                        [1] = 
                                                        {
                                                            ["number"] = 1,
                                                            ["auto"] = true,
                                                            ["id"] = "Tanker",
                                                            ["enabled"] = true,
                                                            ["params"] = 
                                                            {
                                                            }, -- end of ["params"]
                                                        }, -- end of [1]
                                                        [2] = 
                                                        {
                                                            ["number"] = 2,
                                                            ["auto"] = true,
                                                            ["id"] = "WrappedAction",
                                                            ["enabled"] = true,
                                                            ["params"] = 
                                                            {
                                                                ["action"] = 
                                                                {
                                                                    ["id"] = "ActivateBeacon",
                                                                    ["params"] = 
                                                                    {
                                                                        ["type"] = 4,
                                                                        ["AA"] = false,
                                                                        ["callsign"] = "TKR",
                                                                        ["modeChannel"] = "X",
                                                                        ["channel"] = 11,
                                                                        ["system"] = 4,
                                                                        ["unitId"] = 256,
                                                                        ["bearing"] = true,
                                                                        ["frequency"] = 972000000,
                                                                    }, -- end of ["params"]
                                                                }, -- end of ["action"]
                                                            }, -- end of ["params"]
                                                        }, -- end of [2]
                                                        [3] = 
                                                        {
                                                            ["number"] = 3,
                                                            ["auto"] = false,
                                                            ["id"] = "Orbit",
                                                            ["enabled"] = true,
                                                            ["params"] = 
                                                            {
                                                                ["speedEdited"] = true,
                                                                ["pattern"] = "Race-Track",
                                                                ["speed"] = 195.27777777778,
                                                                ["altitude"] = 4876.8,
                                                                ["altitudeEdited"] = true,
                                                            }, -- end of ["params"]
                                                        }, -- end of [3]
                                                    }, -- end of ["tasks"]
                                                }, -- end of ["params"]
                                            }, -- end of ["task"]
                                            ["type"] = "Turning Point",
                                            ["ETA"] = 0,
                                            ["ETA_locked"] = true,
                                            ["y"] = 483.20923951183,
                                            ["x"] = -198114.9394684,
                                            ["formation_template"] = "",
                                            ["speed_locked"] = true,
                                        }, -- end of [1]
                                        [2] = 
                                        {
                                            ["alt"] = 4876.8,
                                            ["action"] = "Turning Point",
                                            ["alt_type"] = "BARO",
                                            ["speed"] = 198.47071619147,
                                            ["task"] = 
                                            {
                                                ["id"] = "ComboTask",
                                                ["params"] = 
                                                {
                                                    ["tasks"] = 
                                                    {
                                                    }, -- end of ["tasks"]
                                                }, -- end of ["params"]
                                            }, -- end of ["task"]
                                            ["type"] = "Turning Point",
                                            ["ETA"] = 503.85160191391,
                                            ["ETA_locked"] = false,
                                            ["y"] = 100482.99752558,
                                            ["x"] = -198114.97512801,
                                            ["formation_template"] = "",
                                            ["speed_locked"] = true,
                                        }, -- end of [2]
                                    }, -- end of ["points"]
                                }, -- end of ["route"]
                                ["groupId"] = 47,
                                ["hidden"] = false,
                                ["units"] = 
                                {
                                    [1] = 
                                    {
                                        ["alt"] = 4876.8,
                                        ["alt_type"] = "BARO",
                                        ["livery_id"] = "usaf standard",
                                        ["skill"] = "High",
                                        ["speed"] = 195.21709789325,
                                        ["type"] = "S-3B Tanker",
                                        ["unitId"] = 256,
                                        ["psi"] = -1.5707966833917,
                                        ["y"] = 483.20923951183,
                                        ["x"] = -198114.9394684,
                                        ["name"] = "Aerial-1-1",
                                        ["payload"] = 
                                        {
                                            ["pylons"] = 
                                            {
                                            }, -- end of ["pylons"]
                                            ["fuel"] = "7813",
                                            ["flare"] = 30,
                                            ["chaff"] = 30,
                                            ["gun"] = 100,
                                        }, -- end of ["payload"]
                                        ["heading"] = 1.5707966833917,
                                        ["callsign"] = 
                                        {
                                            [1] = 1,
                                            [2] = 1,
                                            [3] = 1,
                                            ["name"] = "Texaco11",
                                        }, -- end of ["callsign"]
                                        ["onboard_num"] = "010",
                                    }, -- end of [1]
                                }, -- end of ["units"]
                                ["y"] = 483.20923951183,
                                ["x"] = -198114.9394684,
                                ["name"] = "Aerial-1",
                                ["communication"] = true,
                                ["start_time"] = 0,
                                ["frequency"] = 260,
                            }, -- end of [1]
                        }, -- end of ["group"]
                    }, -- end of ["plane"]
                }, -- end of [1]
            }, -- end of ["country"]
        }, -- end of ["blue"]

    }, -- end of ["coalition"]
    ["sortie"] = "DictKey_sortie_5",
    ["version"] = 20
} -- end of mission
