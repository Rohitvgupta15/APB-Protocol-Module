`include "slave_1.sv"

module apb_master #(parameter N=32,
                               depth = 256)(
  input PCLK,PRESETn,PREADY,
  input [N-1:0]PRDATA,     
  input pwrite,pselx,      
  input [$clog2(depth) - 1:0]paddr, // Address for memory (256 depth, 8-bit addressing)
  input [N-1:0]pwdata,
  input PSLVERR,
    
  output reg PSEL,PENABLE,
  output reg [$clog2(depth) - 1:0]PADDR,
  output reg [N-1:0]PWDATA,
  output reg PWRITE
);
  
  // State machine definition
  reg [1:0] state,next_state;
  parameter IDLE = 2'b00,
  SETUP = 2'b01,
  ACCESS = 2'b10;
  
  // Logic for current state update
  always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
      state <= IDLE;
    end 
    else begin
      state <= next_state;
    end
  end
  
  always @(PREADY or pselx or pwrite or state) begin 
    if(!PRESETn) begin
      PSEL <= 0;
      PADDR <= 0;
      PWDATA <= 0;
      PWRITE <= 0;
      PENABLE <= 0;
    end 
    else begin
      case(state) 
        IDLE: begin
          PENABLE <= 0;
          PSEL <= pselx;
          if(pselx)begin 
            next_state <= SETUP;
          end
          
          else begin
            next_state = IDLE;
          end
        end
        
        SETUP: begin
          PENABLE <= 0;
          PADDR <= paddr;
          PWRITE <= pwrite;
          if(pwrite)begin
            PWDATA <= pwdata;
          end
          next_state <= ACCESS;
         
        end
        
        ACCESS: begin
           PENABLE <= 1;
     //     if(!PSLVERR) begin
           if(PREADY) begin
             if(!pselx) begin
                next_state <= IDLE;  // Return to IDLE state once ready and slave is not selected
              end
              else begin
                next_state <= SETUP;  // Return to SETUP state once ready and slave is selected
              end
            end
            else begin
            next_state <= ACCESS;  // Stay in ACCESS state if not ready
            end
        end
        default : next_state <= IDLE;
      endcase
    end
 
  end
endmodule
