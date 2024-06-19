$gtk.reset
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
HALF_SCREEN_X = SCREEN_WIDTH / 2
HALF_SCREEN_Y = SCREEN_HEIGHT / 2
TILE_HEIGHT = 50
TILE_WIDTH = 125
GRID_WIDTH = 3
GRID_HEIGHT = 3
HALF_TILE_WIDTH = TILE_WIDTH / 2
HALF_TILE_HEIGHT = TILE_HEIGHT / 2

#LA CLAVE PARA HACER TASK TEMPORALES ESTÁ EN SVE_DATA Y QUE ESTA SOLO GUARDE EN OTRA ARRAY QUE SE VA A CARGAR CADA LUNES
#Cambiar el usar el limit como criterio para la creación de objeto que es un poco usado como hack
#Cubrir los casos en los que el usuario escribe algo en subtasks que no sea yes o no
#cubrir que solo se pueda apretar el botón de next hasta que se llene todo 
#VIGILAR COMO VA MI FUNCIÓN DE RESET EL LUNES Y EL PRIMER LUNES DEL MES
class TimeManageTool

  def initialize args
    @args = args
    @has_subtasks = true
    @overwrite_data_flag = false
    @main_button_text ||= "NEW TASK"
    @create = false

  end

  class  TasksAndSubTasks
    def initialize(task, subtasks, sub_objective, has_subtasks)
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

    def generated_task_and_subtask_hash #The main function to create the object using the previous functions
      generated_task ||= {generate_task => generate_sub_task }
    end

  end

  def main_screen()
    initial_tasks()
    objectives()
    save_data()
    load_data()
    main_array()
    substract()
    time_reset()
    main_buttons_functionality()
    if @clicked_new_task == nil #Makes it so objective colors are only present when task or subtasks are present
      objective_color_indicator()
    end
    new_task_screen()
    render()
    debug()
  end

  def initial_tasks() #Creates new tasks with their respective subtasks as objects to populate the main array
    SAVE_DATA = "save_data.txt"

    @programar ||= TasksAndSubTasks.new('PROGRAMAR',[], [5], true).generated_task_and_subtask_hash

    @smash ||= TasksAndSubTasks.new('SMASH', ['PARTIDAS', 'FUNDIES', 'OTRAS'], [2, 2, 1], true).generated_task_and_subtask_hash

    @caminar ||= TasksAndSubTasks.new('CAMINAR',['SOLO', 'PERRO'],[3, 2], false).generated_task_and_subtask_hash

    @leer ||= TasksAndSubTasks.new('LEER', [], [3], false).generated_task_and_subtask_hash

    @initial_tasks ||= [ @programar, @caminar, @leer ]

    @reset_tasks = [ @programar, @caminar, @leer ]

    @temporary_tasks = [@programar, @caminar, @leer]
  end

  def save_data()
    SAVE_DATA = "save_data.txt"

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
    render_new_task_button()
  end

  def render_grid_and_items()
    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH) + HALF_SCREEN_X
        grid_y = (index_y * TILE_HEIGHT) + HALF_SCREEN_Y

        @main_buttons_y_position = (index_y - 10) - TILE_HEIGHT + HALF_SCREEN_Y # Used for new, edit, and back buttons in the main buttons function 
        task_grid_traits = {x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g: 0, b: 0 }
        task_grid_items_traits = {x: grid_x + HALF_TILE_WIDTH, y: grid_y + HALF_TILE_HEIGHT, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{item}"}

        @args.outputs.borders << task_grid_traits
        @args.outputs.labels << task_grid_items_traits

      end
    end
  end

  def main_array() #Function determines what content goes on the main array to be displayed in the render function
    @task_array = []

    @main_array = @task_array

    @loaded_data.each do |hash| #The main content (The tasks and subtasks) is loaded from the save_data.txt
      hash.each_pair do |key, value|
        @task_array.append(key)
          if key[0] == @clicked_subtask && value != [] #Displays related subtasks to clicked tasks, if it has one
           @main_array = value
          end

          if @clicked_new_task == "New Task" #If NEW TASK button is pressed displays the options to create a new task
            @main_array = @new_task
          end
      end
    end
  end

  def objectives #If the task has  subtasks, adds all the subobjectives in an array, and makes a sum to determine the current objective value also limits the goal reached to 0
    @initial_tasks.each do |task_object|
     task_object.each_pair do |task, subtask|
      
        objective = task[1]
        if objective <= 0 # Limits objective completion to 0
          task[1] = 0 
        end

        sub_objective_array = []

        subtask.each_with_index do |array, index|
          sub_objective = array[1]
          sub_objective_array.append(sub_objective)
          task[1] = sub_objective_array.sum
          if sub_objective <= 0 #Limits subobjective completion to 0
            array[1] = 0
          end
        end
      end
    end
  end

  def main_buttons_functionality() #If task has no subtasks, adds or substracts from objective, if it has subtasks takes you to subtask menu to add them individually
    @create = false
    @clicked_task = nil
    @clicked_subtask ||= nil
    @clicked_new_task ||= nil

    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH + HALF_SCREEN_X)
        grid_y = (index_y * TILE_HEIGHT + HALF_SCREEN_Y)
        task_grid_traits = {x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT}
        main_buttons_x_positions =  (index_x * TILE_WIDTH) + HALF_SCREEN_X
        create_task_button = {x: main_buttons_x_positions, y: @main_buttons_y_position, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g:0, b: 255}
        if @args.inputs.mouse.click
          if mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == '-'
            @clicked_task = @main_array[index_y][0] #Copies the task to variable to later be compared in the substract array to substract to the objective if it doesn't have subtasks

            if @main_array == @task_array #If it has subtasks it changes main array to the subtask array instead of substracting
              @clicked_subtask = @main_array[index_y][0]
            end

          elsif mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == 'BACK' #Gets back to the main grid if button is
            @clicked_subtask = nil

          elsif mouse_click(@args.inputs.mouse.point, @create_task_button) && @new_task_buttons[0] == "NEW TASK" #Changes from the main task and subtask screen to the new task creator
            @clicked_new_task = "New Task"
            
          elsif mouse_click(@args.inputs.mouse.point, @create_task_button ) && @main_button_text == "CREATE" #Creates the new task and gets back to the task and subtask screen when this button is pressed
            @create = true
               
          elsif mouse_click(@args.inputs.mouse.point, @create_task_button) && @new_task_buttons[0] == "BACK"
            $gtk.reset
          end
        end
      end
    end
  end

  def substract()
    @initial_tasks.each do |hash|
      hash.each_pair do |tasks, subtasks|
        if @clicked_task == tasks[0] && subtasks == []
          tasks[1] -=1
          @overwrite_data_flag = true
        end
        subtasks.each do |subtask|
          if @clicked_task == subtask[0]
            subtask[1] -= 1
            @overwrite_data_flag = true
          end
        end
      end
    end
  end

  def objective_color_indicator #Changes row colors to indicate how close to reaching objective it is, also limits goal to 0

    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH) + HALF_SCREEN_X
        grid_y = (index_y * TILE_HEIGHT) + HALF_SCREEN_Y

         row_color = { x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g: 0, b: 0 }
         objective = @main_array[index_y][1]

        case
        when objective >= 3
          row_color[:r] = 255
        when objective > 0 && objective <= 3
          row_color[:r] = 255
          row_color[:g] = 255
        when objective <= 0
          row_color[:g] = 255
        end

      @args.outputs.solids << row_color
      end
    end
  end

  def time_reset # Resets task objectives every monday
    MONDAY_FILE = "current_monday.txt"
    time = Time.new

    weekday = time.wday
    day_of_the_month = time.day

    current_day = @args.gtk.read_file(MONDAY_FILE).to_i

    # makes sure the reset time is always on monday
    if day_of_the_month < current_day
     first_monday_of_month = (1..7).find { |d| Time.new(time.year, time.month, d).monday? }

      @args.gtk.write_file(MONDAY_FILE, "#{first_monday_of_month}")
      @args.gtk.write_file(SAVE_DATA, "#{@reset_tasks}")

    elsif day_of_the_month > current_day + 6
      @args.gtk.write_file(SAVE_DATA, "#{@reset_tasks}")
      @args.gtk.write_file(MONDAY_FILE, "#{(day_of_the_month - weekday + 1)}")
    end
  end

  def render_new_task_button
    
    @new_task_buttons ||= ["NEW TASK"]

    if @clicked_new_task == "New Task"
      @new_task_buttons = ["BACK"]
    end

    if @new_task_object.length >= 3
      @new_task_buttons = ["BACK", "CREATE"]
    end
    
    #@new_task_buttons.each do |buttons| 
      #@main_button_text = buttons
    #end


    @new_task_buttons.each_with_index do |item, index_x|
      main_buttons_x_positions =  (index_x * TILE_WIDTH) + HALF_SCREEN_X
      centered_text_width = 50
      centered_text_height = 25

      @create_task_button_borders = {x: main_buttons_x_positions, y: @main_buttons_y_position, w: TILE_WIDTH, h: TILE_HEIGHT, r: 255, g:255, b: 255} 
      @create_task_button = {x: main_buttons_x_positions, y: @main_buttons_y_position, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g:0, b: 255} 
      @create_task_text = {x: main_buttons_x_positions + centered_text_width, y: @main_buttons_y_position + centered_text_height , anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255, text:item}

      @args.outputs.borders << @create_task_button_borders
      @args.outputs.solids << @create_task_button
      @args.outputs.labels << @create_task_text

    end
  end

  def new_task_screen()
    new_task_screen_arrays_and_variables()
    create_task_current_screen()
    new_task_grid()
    #create_objective_or_sub_objective_sceen()
    new_task_user_input()
    new_task_has_subobjective?()
    create_new_task()
    #create_button()
    new_subtasks_and_subobjectives()
    #back()
  end

  def new_task_screen_arrays_and_variables()
    @current_screen||= 0
    @new_task_object ||= []
  end

  def create_task_current_screen() #Takes the user to the appropiate screen, depending of if he wants to create a task with a single objective or a task with multiple subtasks and subobjectives
    @current_screen||= 0
    @required_screen ||= nil #Variable that changes depending if new task created has subtasks or doesn't, and along with the current_screen variable takes to the appropiate screen when creating a new task

    if @required_screen != nil && @current_screen >= @required_screen
      @current_screen = @required_screen
    end
  end

  def new_task_grid()
    @new_task_options = [["TASK", nil], ["Subtasks?", nil], ["Objective", nil],[ "Subobjectives", nil, nil ], []] #What's displayed on the current screen for the user to add its input on each division
    @new_task = [ @new_task_options[ @current_screen ] ]

    @new_task.each_with_index do |new_task, index_y|
      new_task.each_with_index do |element, index_x|
        @grid_x = (index_x * TILE_WIDTH + HALF_SCREEN_X)
        @new_task_grid_y = (index_y * TILE_HEIGHT + HALF_SCREEN_Y)

        task_grid_traits = {x: @grid_x, y: @new_task_grid_y, w: TILE_WIDTH, h: TILE_HEIGHT}
        
        if @args.inputs.mouse.click
          if mouse_click(@args.inputs.mouse.point, task_grid_traits) && element == nil
              @start_typing = true
          end
        end
      end
    end
  end

  def new_task_has_subobjective?() #Complementary function that determines if a task has a subtask or not, based on user input, to be used with other functions to create the task
    has_new_subtasks ||= nil
    
    @new_task.each do |task|
      task.each do |task_traits|
        if @word == "yes" && task_traits == "Subtasks?"
          has_new_subtasks = true
          @required_screen = 3
          
        elsif @word == "no" && task_traits == "Subtasks?"
          has_new_subtasks = false
          @required_screen = 2
        end
      end
    end
    return has_new_subtasks
  end
    
  def new_task_user_input #Takes the parameters from user input to create the task, like the taask name, objectives, wether it has subobjectives or not, and if it has them, the su_tasks and subobjectives
    @user_input ||= []
    @start_typing ||= false
    @word = @user_input.join()
     
    @user_input.append(@args.inputs.text.first) #adds the characters that the user_input array to process them as full words

    if @start_typing == true 
      @args.outputs.labels << {x: @grid_x + 60, y: @new_task_grid_y + 25, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@word}"} #shows on the screen what the user is typing
      
      if @args.inputs.keyboard.key_down.enter #Takes user input in the Task screen and has subobjective screen and takes user to the next screen 
        if new_task_has_subobjective? == nil
        @new_task_object.append(@word)
        @user_input = []
        @start_typing = false
        @current_screen += 1
      
        elsif new_task_has_subobjective? == true # If the task has a sub objective takes input from the user in the sub objective screen
        @new_task_object.append(new_task_has_subobjective?)
        @user_input = []
        @start_typing = false
        @current_screen += 2
        
        else
        @new_task_object.append(new_task_has_subobjective?) #If the screen doesn't have a sub objective takes the input on the objective screen
        @user_input = []
        @start_typing = false
        @current_screen += 1
        end
      end
    end    
    @args.outputs.labels << {x: 1280 / 2, y: 250, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@new_task_object}"}
  end

  def new_subtasks_and_subobjectives #Creates the subtasks and subobjective array for creating a new task object that has subtasks
    @new_subtasks ||= []
    @new_subobjectives = []
    @new_subtasks_and_subobjectives = {}

    if @args.inputs.keyboard.key_down.enter && @current_screen > 3 #starts creating the array if the create tasks function goes to the subtasks screen
      @new_subtasks.append(@word)
    end

    @new_subtasks.each_slice(2) do |key, value| #Makes the sub_task the key, and the sub_objective the value in the array to be used by the object creator
      @new_subtasks_and_subobjectives[key] = value
    end
    
    @args.outputs.labels << {x: 1280 / 2, y: 75, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@new_subtasks_and_subobjectives}"} 
  end

  def create_new_task() #Creates the new task object and adds them to the main task array
    @add_new_task = false
    subtask = []
    sub_objective = []
    
    if @create == true
      if @new_task_object[2] != nil # Makes sure every element of the object is typed before creating the object
    
       if @required_screen == 2 # If the user choses the task doesn't have sub tasks or sub objectives it creates an object without them
          new_object = TasksAndSubTasks.new(@new_task_object[0].upcase,[],[@new_task_object[2].to_i], @new_task_object[1] ).generated_task_and_subtask_hash
       elsif @required_screen == 3
          @new_subtasks_and_subobjectives.each_pair do |key, value|
            subtask.append(key.upcase)
            sub_objective.append(value.to_i)
          end
          new_object = TasksAndSubTasks.new(@new_task_object[0].upcase, subtask, sub_objective, @new_task_object[1]).generated_task_and_subtask_hash #If the user choses the task has sub tasks and sub objectives, it creates one
        end
        
        @clicked_new_task = nil
        
        @add_new_task = true
        $gtk.reset
      end
        
        @initial_tasks.append(new_object) #Adds the new created task to the main array and saves it
        @args.gtk.write_file(SAVE_DATA, "#{@initial_tasks}")

    end
  end
  
  def back()
    @new_task_buttons.each_with_index do |item, index_x|
      main_buttons_x_positions =  (index_x * TILE_WIDTH) + HALF_SCREEN_X
      create_task_button = {x: main_buttons_x_positions, y: @main_buttons_y_position, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g:0, b: 255}     
      
      if @main_array == @new_task 
        if @args.inputs.mouse.click  
          if mouse_click(@args.inputs.mouse.point, create_task_button) && item == "BACK"
            $gtk.reset
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
    @args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@new_task_buttons[0]}"}
    
  end

  def tick

    main_screen()

  end

end

def tick(args)
  args.state.app ||= TimeManageTool.new(args)
  args.state.app.tick
end


