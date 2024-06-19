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

#Cubrir los casos en los que el usuario escribe algo en subtasks que no sea yes o no
#cubrir que solo se pueda apretar el botón de next hasta que se llene todo 
#VIGILAR COMO VA MI FUNCIÓN DE RESET EL LUNES Y EL PRIMER LUNES DEL MES
#En caso de fallo de inital tasks, saber que le quitè el || para agregarv nuevas tasks
class TimeManageTool

  def initialize args
    @args = args
    @buttons = "a"
    @has_subtasks = true
    @test = true
    @save_data ||= []
    @overwrite_data_flag = false

    @substact = false

    @monday ||= false
    @main_button_text ||= "NEW TASK"

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
    objectives()

    save_data()
    load_data()
    main_array()


    render()
    buttons()
    substract()
    time_reset()


    
    new_task_screen()


    debug()
  end

  def initial_tasks()
    SAVE_DATA = "save_data.txt"

    @programar ||= TasksAndSubTasks.new('PROGRAMAR',[], [5], true).generated_task_and_subtask_hash

    @smash ||= TasksAndSubTasks.new('SMASH', ['PARTIDAS', 'FUNDIES', 'OTRAS'], [2, 2, 1], true).generated_task_and_subtask_hash

    @ejercicio ||= TasksAndSubTasks.new('EJERCICIO',['CAMINAR', 'PERRO'],[3, 2], false).generated_task_and_subtask_hash

    @leer ||= TasksAndSubTasks.new('LEER', [], [3], false).generated_task_and_subtask_hash

    @initial_tasks = [ @programar, @smash, @ejercicio, @leer ]

    @reset_tasks ||= [ @programar, @smash, @ejercicio, @leer ]








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
    #if @new_task_screen == false
      render_grid_and_items()
      render_new_task_button()
      if @clicked_new_task == nil
        objective_color_indicator()
      end
    #else
      #render_new_task_screen()
    #end
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

          if @clicked_new_task == "New Task"

            @main_array = @new_task
            #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@main_array}"}

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

       end
     end
   end
 end

  def buttons() #If task has no subtasks, adds or substracts from objective, if it has subtasks takes you to subtask menu to add them individually
    @clicked_task = nil
    @clicked_subtask ||= nil
    @clicked_new_task ||= nil

    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x * TILE_WIDTH + HALF_SCREEN_X)
        grid_y = (index_y * TILE_HEIGHT + HALF_SCREEN_Y)
        task_grid_traits = {x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT}
        create_task_button = {x:grid_x , y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g:0, b: 255}

        if @args.inputs.mouse.click
          if mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == '-'

            @clicked_task = @main_array[index_y][0]

            if @main_array == @task_array
              @clicked_subtask = @main_array[index_y][0]

            end




          elsif mouse_click(@args.inputs.mouse.point, task_grid_traits) && @main_array[index_y][index_x] == 'BACK'
            @clicked_subtask = nil



          elsif mouse_click(@args.inputs.mouse.point, @create_task_button)
            @clicked_new_task = "New Task"









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

  def objective_color_indicator #Changes row colors to indicate how close to reaching objective it is, also limits goal to 0

    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
       grid_x = (index_x * TILE_WIDTH) + HALF_SCREEN_X
       grid_y = (index_y * TILE_HEIGHT) + HALF_SCREEN_Y



       task_grid_traits = { x: grid_x, y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g: 0, b: 0 }

      if @main_array[index_y][1] >=  3
        task_grid_traits[:r] = 255
      elsif @main_array[index_y][1] <= 3 && @main_array[index_y][1] > 0
        task_grid_traits[:r] = 255
        task_grid_traits[:g] = 255
      elsif @main_array[index_y][1] <= 0
        @main_array[index_y][1] = 0
        task_grid_traits[:g] = 255
      end



      @args.outputs.solids << task_grid_traits




      end
    end
  end

  def time_reset # Resets task objectives every monday
    MONDAY_FILE = "monday?.txt"
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
    @main_array.each_with_index do |collumn, index_y|
      collumn.each_with_index do |item, index_x|
        grid_x = (index_x - 3)  + HALF_SCREEN_X
        grid_y = (index_y - 10) - TILE_HEIGHT + HALF_SCREEN_Y
        centered_width = 50
        centered_height = 25

        @create_task_button = {x:grid_x , y: grid_y, w: TILE_WIDTH, h: TILE_HEIGHT, r: 0, g:0, b: 255}
        @create_task_text = {x: grid_x + centered_width, y: grid_y + centered_height , anchor_x: 0.5, anchor_y: 0.5, r: 255, g: 255, b: 255, text:@main_button_text}




      end
    end

    @args.outputs.solids << @create_task_button
    @args.outputs.labels << @create_task_text
  end

 

  def new_task_screen()
    new_task_screen_arrays_and_variables()
    new_task_grid()
    new_task_behaviour()
    new_task_has_subobjective?()
    create_new_task()
    create_button()
  end

  def new_task_screen_arrays_and_variables()
    @counter ||= 0
    @new_task_options = [["TASK", nil], ["Subtasks?", nil], ["Objective", nil],[ "Subobjectives", nil, nil ], []]
    @new_task = [ @new_task_options[ @counter ] ]
    
    @new_has_subtasks ||= false

    @sub_opbjective = [nil, nil]
    @selected_option = ""
    @selected_option_full ||= []
    @start_typing ||= false
    @word = @selected_option_full.join()
    @object ||= []

  end

  def new_task_grid()
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

  def new_task_behaviour()
    @limit ||= nil

    if @limit != nil && @counter >=  @limit
      @counter = @limit
    end
    
    if @start_typing == true
      @selected_option = @args.inputs.text.first
      
      
        @args.outputs.labels << {x: @grid_x + 60, y: @new_task_grid_y + 25, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@word}"}
      


    end



    if @selected_option != "" && @selected_option != nil
      @selected_option_full.append(@selected_option)
    end

    if @args.inputs.keyboard.key_down.enter && @start_typing == true
      if new_task_has_subobjective? == nil
        @object.append(@word)
        @selected_option_full = []
        @start_typing = false
    
    
        @counter += 1
      
      elsif new_task_has_subobjective? == true
        @object.append(new_task_has_subobjective?)
        @selected_option_full = []
        @start_typing = false
        
    
        @counter += 2
        

      else
        @object.append(new_task_has_subobjective?)
        @selected_option_full = []
        @start_typing = false
        
        @counter += 1
        

      end

    
   


    end

    
    

  
    #@args.outputs.labels << {x: 1280 / 2, y: 50, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@counter}"}
    #@args.outputs.labels << {x: 1280 / 2, y: 50, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@selected_option}"}
    #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@selected_option_full}"}
    #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@limit}"}
    #@args.outputs.labels << {x: 1280 / 2, y: 150, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@start_typing}"}
    
    @args.outputs.labels << {x: 1280 / 2, y: 250, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@object}"}



    #puts @selected_option_full
  end

  def new_task_has_subobjective?()
    has_new_subtasks ||= nil
    
    @new_task.each do |task|
      task.each do |task_traits|
        if @word == "yes" && task_traits == "Subtasks?"
          has_new_subtasks = true
          @limit = 3
          
        elsif @word == "no" && task_traits == "Subtasks?"
          has_new_subtasks = false
          @limit = 2
        end
      end
    end
    return has_new_subtasks
  end

  def create_new_task()
    new_object = @object[0]
    if @create == true
      if @object[2] != nil # Makes sure every element of the object is typed before creating the object
        new_object = TasksAndSubTasks.new(@object[0],[],[@object[2].to_i], @object[1] ).generated_task_and_subtask_hash
        
        @clicked_new_task = nil
        @main_button_text = "NEW TASK"
        
      end
      new_object.each_pair do |key, value|
      #@loaded_data.append(new_object)
      #@initial_tasks.append(new_object)
      
        @main_array.append(key)
        render_grid_and_items()
        objectives()

      end

    end

    puts @main_array

    
    
    
      
  

  end

  def create_button
    @create ||= false
    if @object.length >= 3
      @main_button_text = "CREATE"

    end

    if @args.inputs.mouse.click
      if mouse_click(@args.inputs.mouse.point, @create_task_button) && @main_button_text == "CREATE"
        @create = true
        @main_button_text = "NEW TASK"
        
        
        
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
    #@args.outputs.labels << {x: 1280 / 2, y: 100, anchor_x: 0.5, anchor_y: 0.5, r: 0, g: 0, b: 255, text:"#{@clicked_task}"}

  end








  def tick

    main_screen()

  end

end

def tick(args)
  args.state.app ||= TimeManageTool.new(args)
  args.state.app.tick
end


