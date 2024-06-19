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
   
    render()
  end

  def initial_tasks
    SAVE_DATA = "save_data.txt"
    
    @programar ||= TasksAndSubTasks.new('PROGRAMAR',['VIDEOS', 'PROYECTOS'], [3, 3], true).generated_task_and_subtask_hash
    
    @smash ||= TasksAndSubTasks.new('SMASH', ['PARTIDAS', 'FUNDIES', 'OTRAS'], [2, 2, 1], true).generated_task_and_subtask_hash
    
    @ejercicio ||= TasksAndSubTasks.new('EJERCICIO',[],[1], false).generated_task_and_subtask_hash
    
    @leer ||= TasksAndSubTasks.new('LEER', [], [3], false).generated_task_and_subtask_hash

    @initial_tasks = [ @programar, @smash, @ejercicio, @leer ]

    @args.gtk.write_file(SAVE_DATA, "#{@initial_tasks}")
    
  end

  def load_data
    @loaded_data = eval(@args.gtk.read_file(SAVE_DATA))

    
  end

  def render()
    render_grid_and_items()
  end

  def render_grid_and_items()
    @loaded_data.each do |hash|
      hash.each_pair do |key, value|
        
      end
    end
  end

  
  
  

  def tick
    
    main_screen()
    
  end

end

def tick(args)
  args.state.app ||= TimeManageTool.new(args)
  args.state.app.tick
end
