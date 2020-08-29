// CLK_COUNT = (i_clk_frequency)/(baud_rate)
// Example:
//	50 000 000 Hz/115 200 baud ~ 434
//	50 000 000 Hz/9 600 baud ~ 5208

module uart_tx (
	input i_clk,
	input [7:0] i_data,
	input i_send,
	output o_busy,
	output o_tx
);

parameter CLK_COUNT = 434;	//baud=115200

parameter IDLE = 3'b000;
parameter START_BIT = 3'b001;
parameter DATA_BIT = 3'b010;
parameter STOP_BIT = 3'b011;

reg [2:0] r_state = 0;
reg [12:0] r_counter = 0;
reg [2:0] r_index = 0;
reg r_tx = 1'b1;
reg r_busy = 1'b0;
reg [7:0] r_data;

always @ (posedge i_clk)
	begin
		case(r_state)
			IDLE:
			begin
				r_tx <= 1'b1;
				r_busy <= 1'b0;
				r_counter <= 0;
				r_index <= 0;
				
				if(i_send == 1'b1) 
				begin
					r_data <= i_data;
					r_busy <= 1'b1;
					r_state <= START_BIT;
				end
				else r_state <= IDLE;
			end
			
			START_BIT:
			begin
				r_tx <= 1'b0;			
			
				if(r_counter == CLK_COUNT-1)
				begin
						r_counter <= 0;
						r_state <= DATA_BIT;
				end
				else 
				begin
					r_counter <= r_counter + 1;
					r_state <= START_BIT;
				end
			end
			
			DATA_BIT:
			begin
				r_tx <= r_data[r_index];
			
				if(r_counter == CLK_COUNT-1)
				begin
					r_counter <= 0;
					
					if(r_index<7)
					begin
						r_index <= r_index + 1;
						r_state <= DATA_BIT;
					end
					else
					begin
						r_index <= 0;
						r_state <= STOP_BIT;
					end
				end
				else 
				begin
					r_counter <= r_counter + 1;
					r_state <= DATA_BIT;
				end
			end
			
			STOP_BIT:
			begin
				r_tx <= 1'b1;
			
				if(r_counter == CLK_COUNT-1)
				begin
						r_counter <= 0;
						r_busy <= 1'b0;
						r_state <= IDLE;
				end
				else 
				begin
					r_counter <= r_counter + 1;
					r_state <= STOP_BIT;
				end
			end
			
			default:
			begin
				r_state <= IDLE;
			end
		endcase
	end

	assign o_busy = r_busy;
	assign o_tx = r_tx;
	
endmodule