# ------------------- MAIN PART ----------------- #

# Author: Hau Nguyen     
# Date: 25/5/2025
# Gomoku Game Implementation (5 in a rows, 15 x 15 blank board, 600 seconds time limit, no time added in default mode)

# Macros for complete game functionality
.include "Data_part.mac"
.include "AI_part.mac"
.include "Console_part.mac"
.include "File_part.mac"

# ------------------------------------------------------------------------------
# Main Game Loop
#
# Description: Play a match, print and save result. Then ask for replay
# Main registers: $s0 (current player), $s7 (move count), $t0 (x), $t1 (y),
#                 $t2, $t3, $t4 (temp variables for different purposes),
#                 $v0, $v1 (for result), $a0 (for print strings), $sp (backup)
# ------------------------------------------------------------------------------
.text
.globl main
main:
    # Display Gomoku ASCII art
    display_label
    sw $zero, current_message
    
    # Choose mode, board type, opponent, side
    choose_game_information

# ------------------------------
# GAME INITIALIZATION
# ------------------------------
    game_start:
        # Increase num of games
        lw $t3, game_count
        addi $t3, $t3, 1
        sw $t3, game_count
        
        # Initialize game
        reset_game     # Current player = 1, move count = 0
        
        # Create puzzle board if in puzzle type
        lw $t2, puzzle_type
        beqz $t2, no_puzzle
        generate_random_moves
        no_puzzle:
        create_initial_board
        
# ------------------------------
# MAIN GAME LOOP        
# ------------------------------
    game_loop:
        # ---- Check timeout
        # Check time before each turn
        update_player_time
        check_timeout
        beq $v0, 0, no_timeout
        
        # ---- Timeout case
        out_time:
            # Timeout occurred - current player loses           
            set_time_to_zero
            
            print_board
            la $a0, strTimeout
            li $v0, 4
            syscall
            
            # Switch to other player who wins by timeout
            switch_player
            j timeout_game
            
        # ---- No timeout case
        no_timeout:
            # Print current board
            print_board
                        
            # Display AI move if AI played the last turn
            print_ai_move
            
            # ---- Get player input
            # Check if current player is human or AI
            lw $t2, game_opponent
            beqz $t2, human_turn    # If game_opponent = 0 (human vs human)
        
            # If game_opponent = 1 (human vs AI)
            lw $t3, human_side
            lw $s0, current_player
            beq $s0, $t3, human_turn  # If current player matches human side
        
            # Otherwise it's AI's turn
            j ai_turn
     
            human_turn:
                # Reset AI last move flag
                li $t4, 0
                sw $t4, ai_last_move
                
                # Original human input code
                get_player_input
                sw $v0, move_x    # x or 'u' or 's'
                sw $v1, move_y    # y or 'u' or 's'
            
                # Handle special commands
                li $t2, -1       # 'u' = -1
                beq $v0, $t2, handle_undo     
                li $t2, -2       # 's' = -2
                beq $v0, $t2, handle_surrender
                li $t2, -3       # Timeout = -3
                beq $v0, $t2, out_time
                j make_move
                
            ai_turn:
                # Ask player undo before AI
                lw $s7, move_count
                beqz $s7, no_undo_before_ai_move
                ask_undo_before_ai_move
                beq $v0, 0, no_undo_before_ai_move
                
                # If yes, handle undo before AI, switch to player 1 turn      
                switch_player
                li $t4, 1    # Undo = 1
                lw $s0, current_player
                record_action_history($t4, $s0, $zero, $zero)
                switch_player
                    
                undo_last_move
                j game_loop
                    
            no_undo_before_ai_move:
                # AI's turn
                ai_make_move
                
                # Set flag that last move was by AI
                li $t4, 1
                sw $t4, ai_last_move
                
                update_ai_time      # 5s per move
           
                sw $v0, move_x    # x
                sw $v1, move_y    # y
            
            make_move:            
                # Make the move
                lw $s0, current_player
                lw $t0, move_x
                lw $t1, move_y
                make_move($t0, $t1, $s0)
                
                # Reset undo flag on valid move
                sw $zero, undo_flag
                  
                beq $v0, 1, game_loop  # If occupied (shouldn't happen with AI), try again
                
                # Record the move
                li $t4, 0        # Normal = 0
                lw $s0, current_player
                record_action_history($t4, $s0, $t0, $t1)
                
                lw $s7, move_count
                addi $s7, $s7, 1 # Increase count
                sw $s7, move_count
                
                # Determine side to check, because AI mode not use normal update_player_time
                determine_side_check
            
                human_check:
                    # ---- Check win and find winning line
                    update_player_time
                    check_timeout
                    bne $v0, 0, out_time
                    
                    lw $s0, current_player
                    lw $t0, move_x
                    lw $t1, move_y
                    check_win($t0, $t1, $s0)
                    bne $v0, 0, game_over
                    
                    # ---- Check tie
                    update_player_time
                    check_timeout
                    bne $v0, 0, out_time
                    
                    check_tie
                    bne $v0, 0, tie_game
                    
                    # ---- Switch player
                    update_player_time
                    check_timeout
                    bne $v0, 0, out_time
                    
                    switch_player
                    j game_loop
                    
                ai_check:   
                    # ---- Check win
                    check_ai_timeout
                    bnez $v0, out_time
                    
                    lw $s0, current_player
                    lw $t0, move_x
                    lw $t1, move_y
                    check_win($t0, $t1, $s0)
                    bne $v0, 0, game_over
                    
                    # ---- Check tie
                    check_ai_timeout
                    bnez $v0, out_time
                    
                    check_tie
                    bne $v0, 0, tie_game
                    
                    # ---- Switch player
                    check_ai_timeout
                    bnez $v0, out_time
                    
                    switch_player
                    j game_loop

# ------------------------------
# SPECIAL COMMAND HANDLERS
# ------------------------------
        handle_undo:
            switch_player
            li $t4, 1    # Undo = 1
            lw $s0, current_player
            record_action_history($t4, $s0, $zero, $zero)
            switch_player
            
            undo_last_move
            j game_loop
            
        handle_surrender:
            li $t4, 2    # Surrender = 2
            lw $s0, current_player
            record_action_history($t4, $s0, $zero, $zero)
            
            update_player_time
            check_timeout
            bne $v0, 0, out_time       
            
            # Store surrender message for next display
            la $t4, strSurrender
            sw $t4, current_message
    
            # Current player surrender, the other win
            update_player_time
            switch_player
            j surrender_game
            
# ------------------------------
# GAME END CONDITIONS
# ------------------------------
    game_over:
        li $t2, 0     # No tie = 0
        update_score($t2)
        print_board
        
        save_result
        lw $s0, current_player
        display_win_message($s0)
        
        # Check if surrender or timeout
        lw $t3, last_move_x
        li $t2, -1
        beq $t3, $t2, show_surrender_message
        li $t1, -2
        beq $t3, $t2, show_timeout_message
        
        # Normal win
        display_win_line
        j ask_replay_prompt
        
        show_surrender_message:
            la $a0, strWinBySrd
            li $v0, 4
            syscall
            j ask_replay_prompt
            
        show_timeout_message:
            la $a0, strWinByTo
            li $v0, 4
            syscall
            j ask_replay_prompt
    
    surrender_game:  
        li $t2, 0    # No tie = 0
        update_score($t2)    
        print_board
        
        # Flag by set last_move_x = -1 (indicates surrender)
        li $t2, -1
        sw $t2, last_move_x
        
        # Save game information to file
        save_result
        
        lw $s0, current_player
        display_win_message($s0)
        
        la $a0, strWinBySrd
        li $v0, 4
        syscall
        j ask_replay_prompt
    
    timeout_game:
        li $t2, 0    # No tie = 0
        update_score($t2)        
            
        switch_player
        li $t4, 3    # Timeout = 3
        lw $s0, current_player
        record_action_history($t4, $s0, $zero, $zero)
        switch_player
        
        # Flag by set last_move_x = -2 (indicates timeout)
        li $t2, -2
        sw $t2, last_move_x
        
        # Save game infor to file
        save_result
        
        lw $s0, current_player
        display_win_message($s0)
        
        la $a0, strWinByTo
        li $v0, 4
        syscall
        j ask_replay_prompt
    
    tie_game:
        li $t2, 1    # Tie = 1
        update_score($t2)
        print_board
        
        # Save game infor to file
        save_result
        display_tie_message

# ------------------------------
# POST-GAME OPTIONS
# ------------------------------
    ask_replay_prompt:
        display_score
        ask_replay
        
        beq $v0, 1, game_start          # If yes (y), restart game with same mode
        beq $v0, 2, choose_mode_again   # If mode (m), choose new mode first
        j exit                          # If no (n), exit
        
    choose_mode_again:
        choose_game_information
        j game_start            # Then start new game

# ------------------------------
# PROGRAM EXIT
# ------------------------------
    exit:
        save_endgame_message
        la $a0, strExit
        li $v0, 4
        syscall 
        
        # Exit
        li $v0, 10
        syscall
        
