module apb_intf;
  
  parameter N=32, depth = 256;
  
//   inputs
  reg PCLK, PRESETn, PWRITE, PSELx;
  reg [$clog2(depth) - 1:0] PADDR;
  reg [N-1:0] PWDATA;
//   outputs
  wire [N-1:0] PRDATA;
  wire PSLVERR, PREADY;
  
  wire [N-1:0]wdata,addr;
  wire write,ENABLE;
  wire sel; 
  
endmodule




module apb_tb #(parameter N=32,
                          depth = 256);
  
//   instance of interface
  apb_intf intf();
  
  apb_master m1(
//     inputs
    .PCLK(intf.PCLK),
    .PRESETn(intf.PRESETn),
    .pwrite(intf.PWRITE),
    .pselx(intf.PSELx),
    .paddr(intf.PADDR),
    .pwdata(intf.PWDATA),
    .PRDATA(intf.PRDATA),
    .PSLVERR(intf.PSLVERR),
    .PREADY(intf.PREADY),
//     outputs
    .PWRITE(intf.write),
    .PSEL(intf.sel),
    .PADDR(intf.addr),
    .PWDATA(intf.wdata),
    .PENABLE(intf.ENABLE)
  );
  
  apb_slave s1(
//     inputs
    .PCLK(intf.PCLK),
    .PRESETn(intf.PRESETn),
    .PSEL(intf.sel),
    .PENABLE(intf.ENABLE),
    .PWRITE(intf.write),
    .PADDR(intf.addr),
    .PWDATA(intf.wdata),
//     outputs
    .PRDATA(intf.PRDATA),
    .PSLVERR(intf.PSLVERR),
    .PREADY(intf.PREADY)
  );
  
  initial begin
    $monitor("RESET=%0h, PWRITE=%0h, PSELx=%0h, PREADY=%0h, PADDR=%0h, PWDATA=%0h, PRDATA=%0h, PSLVERR=%0h, PENABLE=%0h", intf.PRESETn, intf.PWRITE, intf.PSELx, intf.PREADY, intf.PADDR, intf.PWDATA, intf.PRDATA, intf.PSLVERR, intf.ENABLE);
  end
  
//   write task
  task write(input [$clog2(depth) - 1:0]addr,[N-1:0]data);
    intf.PSELx = 1;
    @(posedge intf.PCLK)
    intf.PWRITE = 1;
    intf.PADDR = addr;
    intf.PWDATA = data;
    @(posedge intf.PCLK);
  endtask
  
//   read task
  task read(input [$clog2(depth) - 1:0]addr);
    intf.PSELx = 1;
    @(posedge intf.PCLK)
    intf.PWRITE = 0;
    intf.PADDR = addr;
    @(posedge intf.PCLK);
  endtask
  
//   reset task
  task reset();
    intf.PRESETn = 0;
    intf.PSELx = 0;
    #22 intf.PRESETn = 1;
  endtask
 
  
  initial begin
    intf.PCLK = 1;
    reset;
    
//     simple write & read
    if ($test$plusargs ("sanity_test")) begin
      $display("simple read write operation is going on");
      write(8'd16, 32'h11223344);
      read(8'd16);
      #12 reset;

    end
    
//     multiple write
    if ($test$plusargs ("multiple_write_read_test")) begin
      $display("multiple read write operation");

      write(8'd00, 32'h22334455);
      write(8'd04, 32'h33667788);
      write(8'd08, 16'hdeef);
      write(8'd12, 16'hbeef);
      
      
//     multiple read
      read(8'd00);
      read(8'd04);
      read(8'd08);
      read(8'd12);
      #72 reset;

    end
    
//     multiple read write with asynchronous reset
    if ($test$plusargs ("multiple_write_async_reset_read_test")) begin
      $display("multiple write asynchronous reset read test");

      write(8'd00, 32'h22334455);
      write(8'd04, 32'h33667788);
       reset;
      write(8'd08, 16'hdeef);
      write(8'd12, 16'hbeef);
      
      
//     multiple read
      read(8'd00);
      read(8'd04);
      read(8'd08);
      read(8'd12);
      #12 reset;

    end
    
    //     error scenario (try to access unauthorized location)
    if ($test$plusargs ("unauthorized_location_error_test")) begin
      $display("slave error generation");
      write(8'hbb, 8'h99);
      read(8'hbb);
      #12 reset;
    end
      
  end
  
  always #5 intf.PCLK = ~intf.PCLK;
  
  initial begin
    $dumpfile("apb_tb.vcd");
    $dumpvars;
    #470 $finish;
  end
  
endmodule
