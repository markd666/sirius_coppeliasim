--[[
Function to print to console easier than typing out the long winded way...
]]--
printf = function(stringToPrint)
    sim.addLog(sim.verbosity_scriptinfos, stringToPrint)
end

--[[
    Wraps the 'isHandleValid' function call, prints to console an error and stops the simulations.
]]--
checkForValidHandle = function(handle, handleType)
    result=sim.isHandleValid(handle,handleType)
    
    if result == -1 then
        printf("Error: Handle check unsuccesful")
        sim.stopSimulation()
    elseif result == 0 then
        printf("Error: Handle check unsuccesful")
        sim.stopSimulation()
    end
end

--[[
    Check a handle to an object is valid
]]--
checkForValidJointHandle = function(handle)
  checkForValidHandle(handle,sim.appobj_object_type)
end

--[[
    Check IK type handle is valid
]]--
checkForValidIKHandle = function(handle)
    checkForValidHandle(handle,sim.appobj_ik_type)
end

--[[
 Check for valid collection handles
]]--
checkForValidCollectionHandle = function(handle)
    checkForValidHandle(handle,sim.appobj_collection_type)
end


--[[
    Targets are end effector goal poses. Check their a valid object
    but could also add checks for valid orientation.
]]--
checkForValidTargetHandle = function(handle)
    checkForValidHandle(handle,sim.appobj_object_type)
end

--[[
    Check a table of joint handles if have all 6 joints (6dof UR10)
]]--
checkAllUR10JointHandlesValid = function(referenceString, jointHandleTable)
    checkAllJointHandlesValid(referenceString, jointHandleTable, 6)
end

checkAllJointHandlesValid = function(referenceString, jointHandleTable, manupulatorsDofNumber)
    sizeOfJointHandleTable = table.getn(jointHandleTable)
    if sizeOfJointHandleTable == nil then
        printf("Error getting joint handle table size! Line: "..referenceString)
        sim.stopSimulation()
    elseif sizeOfJointHandleTable ~= manupulatorsDofNumber then
        printf("Error: Incorrect joint handle table size of: "..tostring(sizeOfJointHandleTable))
        sim.stopSimulation()
    end
    
    for i=1,#jointHandleTable, 1 do
        checkForValidJointHandle(jointHandleTable[i])
    end
end

--[[
  Return a table of joint positions for the UR10
]]--
getUR10JointPositions=function(jointHandles)
    -- Returns the current robot configuration
    checkAllUR10JointHandlesValid("getUR10JointPositions", jointHandles)

    local config={}
        for i=1,#jointHandles,1 do
            config[i]=sim.getJointPosition(jointHandles[i])
        end
    return config
end

--[[
    Set joint positions for the UR10. Argument is a table containing 6 joint positions 
]]--
setUR10JointPositions=function(jointHandleTable, jointPositionsTable)
    -- Applies the specified configuration to the robot
    checkAllUR10JointHandlesValid("setUR10JointPositions",jointHandleTable)
    local positionTableSize = table.getn(jointPositionsTable)
    if positionTableSize ~=6 then
        printf("Error: setUR10JointPositions. Incorrect joint posiiton size table. Expected ==6. Actual: "..positionTableSize)
        sim.stopSimulation()
    end

    if jointPositionsTable then
        for i=1,#jh,1 do
            sim.setJointPosition(jointHandleTable[i],jointPositionsTable[i])
        end
    end
end

--[[
    Set the mode for all the joints in UR10 to passive which is used for IK mode.
]]--
setUR10JointsForIKMode = function(jointHandleTable)
    local not_hybrid_mode = 0
    for i=1, #jointHandleTable, 1 do
        sim.setJointMode(jointHandleTable[i],sim.jointmode_passive, not_hybrid_mode)
    end
end


--[[
    getUR10JointHandles
]]--
getUR10JointHandles = function()
     -- Initialization phase:
    local jointHandleTable={-1,-1,-1,-1,-1,-1}
      
    for i=1,6,1 do
        jointHandleTable[i]=sim.getObjectHandle('UR10_joint'..i)
    end
    checkAllUR10JointHandlesValid("getUR10JointHandles", jointHandleTable)

    return jointHandleTable
end


--[[
     -- Allows or forbids automatic thread switches.
    -- This can be important for threaded scripts. For instance,
    -- you do not want a switch to happen while you have temporarily
    -- modified the robot configuration, since you would then see
    -- that change in the scene display.
]]--
forbidThreadSwitches=function(forbid)
    if forbid then
        forbidLevel=forbidLevel+1
        if forbidLevel==1 then
            sim.setThreadAutomaticSwitch(false)
        end
    else
        forbidLevel=forbidLevel-1
        if forbidLevel==0 then
            sim.setThreadAutomaticSwitch(true)
        end
        
    end
end