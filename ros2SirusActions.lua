--[[
    Functions to deal with ROS 2 'actions' messaging style between coppeliasim and unity
    Info @ https://github.com/ros2/rcl_interfaces/tree/master/action_msgs
 ]]--
 require "helperFunctions"

 ros2SirusActionsWorks = function ()
     printf("ros2SirusActionWorks")
 end

 function actsrv_handle_goal(goal_id,goal)
    printf(string.format('actsrv_handle_goal: goal_id=%s, goal=%s',goal_id,table.tostring(goal)))

    if current_goal then
        return simROS2.goal_response.reject
    end
    if goal.order > 9000 then
        return simROS2.goal_response.reject
    else
        return simROS2.goal_response.accept_and_execute
    end
end

function actsrv_handle_cancel(goal_id,goal)
    printf(string.format('actsrv_handle_cancel: goal_id=%s, goal=%s',goal_id,table.tostring(goal)))
    if current_goal and current_goal.id==goal_id then
        current_goal=nil
    end
    return simROS2.cancel_response.accept
end

function actsrv_handle_accepted(goal_id,goal)
    printf(string.format('actsrv_handle_accepted: goal_id=%s, goal=%s',goal_id,table.tostring(goal)))
    current_goal={
        id=goal_id,
        order=goal.order,
        status={0, 1},
        mtime=sim.getSystemTime()
    }
end