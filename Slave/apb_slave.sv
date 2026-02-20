module apb_slave #(parameter N=32,
                              DEPTH = 256) ( 
  input [N-1:0] PWDATA,
  input [$clog2(DEPTH) - 1:0] PADDR, // log of base 2
  input PCLK, PRESETn, PSEL, PENABLE, PWRITE,
  output reg [N-1:0] PRDATA,
  output reg PREADY, PSLVERR
);
  reg [7:0] mem[0:DEPTH - 1];
  
   always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      PRDATA <= 0;
      PREADY <= 0;
      PSLVERR <= 0;
    end 
  end
  
  always @(PSEL or PWRITE or PENABLE or PADDR) begin 
    if(PSEL && PWRITE  && PENABLE) begin // write
      if((PADDR <= DEPTH-1) && (PADDR%4==0)) begin // satisfy means address is correct
                 PSLVERR <= 0;
                 PREADY <= 1;
        mem[PADDR] <= PWDATA[7:0]; 
        mem[PADDR+1] <= PWDATA[15:8];
        mem[PADDR+2] <= PWDATA[23:16];
        mem[PADDR+3] <= PWDATA[31:24];
              end
            else begin
              PSLVERR <= 1;
              PREADY <= 1;
              end
    end
    else if(PSEL && !PWRITE &&  PENABLE) begin // read
      if((PADDR <= DEPTH-1) && (PADDR%4==0) ) begin // satisfy means address is correct
                  PSLVERR <= 0;
                  PREADY <= 1;
         PRDATA <= {mem[PADDR+3],mem[PADDR+2],mem[PADDR+1],mem[PADDR]}; 
//          PRDATA <= mem[PADDR];
              end
            else begin
              PSLVERR <= 1;
              PRDATA <= 32'hxxx;
              PREADY <= 1; //
            end  
      
    end
      else begin
        PREADY <=0;
          PSLVERR <= 0;
      end
      
  end

endmodule
