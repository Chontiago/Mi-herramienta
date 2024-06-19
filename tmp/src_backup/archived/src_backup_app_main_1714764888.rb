$gtk.reset
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
HALF_SCREEN_X = SCREEN_WIDTH / 2
HALF_SCREEN_Y = SCREEN_HEIGHT / 2
TILE_HEIGHT = 50
TILE_WIDTH = 100
GRID_WIDTH = 3
GRID_HEIGHT = 3
HALF_TILE_WIDTH = TILE_WIDTH / 2
HALF_TILE_HEIGHT = TILE_HEIGHT / 2

#EMPEZAR A EXPERIMENTAR CON LA FUNCIÓN DE WRITE DE 
class TimeManageTool
  
  def initialize args
    @args = args
    @buttons = "a"
    @has_subtasks = true
    @test = true
    @save_data ||= []
    @overwrite_data_flag = false
    
    @substact = false

  end

  class  TasksAndSubTasks
    def initialize(task, subtasks, sub_objective, has_subtasks)
      @task = task
      @subtasks = subtasks
      @plus = '+'
      @minus = '-'
      @has_subtasks = has_subtasks
      @sub_objective ||= sub_objective

      @back = 'BACK'
      @objective = sub_objective.sum
      
      @task = {task => generate_sub_task()} 
      @save_file = "save_data.txt"
    
    end

      
  def generate_task
      
      @task_array ||= [ @task.keys.first.to_s, @objective, @minus, @plus, @has_subtasks ]

      

    end

    def generate_sub_task 
      
      subtask_menu ||= []
      
      @subtasks.each_with_index do |subtask, index|
        subtask_menu.append( [ subtask, @sub_objective[index],  @minus, @plus, @back ] )
      end

      
    return subtask_menu

    end

    def generated_task_and_subtask_hash 
       
    generated_task ||= {generate_task => generate_sub_task }

    

    
    end

  end

  def main_screen()
    initial_tasks()
    load_data()
    main_array()
    objectives()
   
    render()
    plus_and_minus_button()
    substract()
    
    debug()
  end

  def initial_tasks
    SAVE_DATA = "save_data.txt"
    
    @programar ||= TasksAndSubTasks.new('PROGRAMAR',['VIDEOS', 'PROYECTOS'], [3, 3], true).generated_task_and_subtask_hash
    
    @smash ||= TasksAndSubTasks.new('SMASH', ['PARTIDAS', 'FUNDIES', 'OTRAS'], [2, 2, 1], true).generated_task_and_subtask_hash
    
    @ejercicio ||= TasksAndSubTasks.new('EJERCICIO',[],[1], false).generated_task_and_subtask_hash
    
    @leer ||= TasksAndSubTasks.new('LEER', [], [3], false).generated_task_and_subtask_hash

    @initial_tasks ||= [ @programar, @smash, @ejercicio, @leer ]

    if @overwrite_data_flag == true
      
      @args.gtk.write_file(SAVE_DATA, "#{@initial_tasks}")
      
      @overwrite_data_flag = false
    end
    
  end

  def load_data
    @loaded_data = eval(@args.gtk.read_file(SAVE_DATA))

    if @args.state.tick_count == 1
      @initial_tasks = @loaded_data
    end

    
  end

  def render()
    render_grid_and_items()
  end

  def render_grid_and_items()
    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH) + HALF_SCREEN_X
        grid_y = (index_y * TILE_HEIGHT) + HALF_SCREEN_Y
        
        task_grid_traits = {x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g: 0, b: 0 }
        task_grid_items_traits = {x: grid_x + HALF_TILE_WIDTH, y: grid_y + HALF_TILE_HEIGHT, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{item}"}

        @args.outputs.borders << task_grid_traits
        @args.outputs.labels << task_grid_items_traits
        

       #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{collumn}"}
        
      end
    end
  end



  def main_array()
    @task_array = []

    @main_array = @task_array

    @loaded_data.each do |hash|
      hash.each_pair do |key, value|
        @task_array.append(key)
        
          if key[0] == @clicked_subtask && value != []

          #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{value}"}
         
           @main_array = value
        
          
          
          

          
        end
        

      
      end
    end
    
  end

  def objectives #If the task has  subtasks, adds all the subobjectives in an array, and makes a sum to determine the current objective value
    @initial_tasks.each do |task_object| 
     task_object.each_pair do |task, subtask|
       sub_objective_array = []
       
       subtask.each_with_index do |array, index|
         
         sub_objective_array.append(array[1]) 
         task[1] = sub_objective_array.sum



         
         
       
         #objective_array.append(array[1])
         #key[1] = objective_array.sum
       end
     end
   end
 end

  def plus_and_minus_button() #If task has no subtasks, adds or substracts from objective, if it has subtasks takes you to subtask menu to add them individually
    @clicked_task = nil
    @clicked_subtasks ||= nil

    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH + HALF_SCREEN_X)
        grid_y = (index_y * TILE_HEIGHT + HALF_SCREEN_Y)
        task_grid_traits = {x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT}
        if @args.inputs.mouse.click 
          if mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == '-'
            
            @clicked_task = @main_array[index_y][0]
            
            if @main_array == @task_array
              @clicked_subtask = @main_array[index_y][0]
            end
            

          elsif mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == 'BACK'
            @clicked_subtask = nil
            

          
          end
        end
      end
      
    end

    
  end

  def substract()
    @initial_tasks.each do |hash|
      hash.each_pair do |key, value|
        if @clicked_task == key[0] && value == []
          key[1] -=1
          @overwrite_data_flag = true
        end
        value.each do |subtask|
          if @clicked_task == subtask[0]
            subtask[1] -= 1
            @overwrite_data_flag = true
          
          end
        end
      end
    end
  end

  def mouse_click(box1, box2)
    #box1[:y] < box2[:y] + box2[:h] &&
    #box1[:y] + box1[:h] > box2[:y]
    box1[:x] >= box2[:x] && box1[:x] <= box2[:x] + box2[:w] &&
    box1[:y] >= box2[:y] && box1[:y]  <= box2[:y] + box2[:h]
  end

  def debug()
    @args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@clicked_task}"}
  end

  

  
  
  

  def tick
    
    main_screen()
    
  end

end

def tick(args)
  args.state.app ||= TimeManageTool.new(args)
  args.state.app.tick
end

#Recordar todo el pedo de overwrite data si surge un bug eventuamente