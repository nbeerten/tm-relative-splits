/*
 * Author: Phlarx
 * shttps://github.com/Phlarx/tm-checkpoint-counter/blob/main/CheckpointLib.as
 */

namespace CP
{
    // only checkpoint detection is used from this file, finish and retire are handled differently
    void Checkpoint()
    {
        GUI::CheckpointUpdate();
    }

    /**
     * If true, then this plugin has detected that we are in game, on a map.
     * If false, none of the other values are valid.
     */
    bool inGame = false;
    
    /**
     * If false, then at least one checkpoint tag is a non-standard value.
     * Only applies to NEXT and MP4.
     */
    bool strictMode = false;
    
    /**
     * The ID of the map whose checkpoints have been counted.
     */
    string curMapId = "";
    
    /**
     * The number of checkpoints completed in the current lap.
     */
    uint curCP = 0;
    
    /**
     * The number of checkpoints detected for the current map.
     */
    uint maxCP = 0;
    
    /**
     * Internal values.
     */
    uint preCPIdx = 0;
    
    /**
     * Update should be called once per tick, within the plugin's Update(dt) function.
     */
    void Update() {
        auto playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);
        
        if(playground is null
            || playground.Arena is null
            || playground.Map is null
            || playground.GameTerminals.Length <= 0
            || playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing
            || cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer) is null) {
            inGame = false;
            return;
        }
        
        auto player = cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
        if(player is null) {
            inGame = false;
            return;
        }
        auto scriptPlayer = player.ScriptAPI;
        
        if(scriptPlayer is null) {
            inGame = false;
            return;
        }
        
        if(player.CurrentLaunchedRespawnLandmarkIndex == uint(-1)) {
            // sadly, can't see CPs of spectated players any more
            inGame = false;
            return;
        }
        
        MwFastBuffer<CGameScriptMapLandmark@> landmarks = playground.Arena.MapLandmarks;
        
        if(!inGame && (curMapId != playground.Map.IdName || GetApp().Editor !is null)) {
            // keep the previously-determined CP data, unless in the map editor
            curMapId = playground.Map.IdName;
            preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;
            curCP = 0;
            maxCP = 0;
            strictMode = true;
            
            array<int> links = {};
            for(uint i = 0; i < landmarks.Length; i++) {
                if(landmarks[i].Waypoint !is null && !landmarks[i].Waypoint.IsFinish && !landmarks[i].Waypoint.IsMultiLap) {
                    // we have a CP, but we don't know if it is Linked or not
                    if(landmarks[i].Tag == "Checkpoint") {
                        maxCP++;
                    } else if(landmarks[i].Tag == "LinkedCheckpoint") {
                        if(links.Find(landmarks[i].Order) < 0) {
                            maxCP++;
                            links.InsertLast(landmarks[i].Order);
                        }
                    } else {
                        // this waypoint looks like a CP, acts like a CP, but is not called a CP.
                        if(strictMode) {
                            warn("The current map, " + string(playground.Map.MapName) + " (" + playground.Map.IdName + "), is not compliant with checkpoint naming rules."
                                    + " If the CP count for this map is inaccurate, please report this map on the GitHub issues page:"
                                    + " https://github.com/Phlarx/tm-checkpoint-counter/issues");
                        }
                        maxCP++;
                        strictMode = false;
                    }
                }
            }
        }
        inGame = true;
        
        /* These are all always length zero, and so are useless:
        player.ScriptAPI.RaceWaypointTimes
        player.ScriptAPI.LapWaypointTimes
        player.ScriptAPI.CurrentLapWaypointTimes
        player.ScriptAPI.PreviousLapWaypointTimes
        player.ScriptAPI.Score.BestRaceTimes
        player.ScriptAPI.Score.PrevRaceTimes
        player.ScriptAPI.Score.BestLapTimes
        player.ScriptAPI.Score.PrevLapTimes
        */
        
        if(preCPIdx != player.CurrentLaunchedRespawnLandmarkIndex && landmarks.Length > player.CurrentLaunchedRespawnLandmarkIndex) {
            preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;

            auto waypoint = landmarks[preCPIdx].Waypoint;
            
            if(waypoint is null || waypoint.IsFinish || waypoint.IsMultiLap) {
                // if null, it's a start block. if the other flags, it's either a multilap or a finish.
                // in all such cases, we reset the completed cp count to zero.
                curCP = 0;
            } else {
                curCP++;
                Checkpoint();
            }

            if(waypoint !is null && waypoint.IsFinish) {
                Checkpoint();
            }
        }
    }
}
