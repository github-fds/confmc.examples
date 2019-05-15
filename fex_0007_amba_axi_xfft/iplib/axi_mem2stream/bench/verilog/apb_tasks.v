`ifndef _APB_TASKS_V_
`define _APB_TASKS_V_
   // generate a read transaction for 4 byte on AMBA APB
   // apb_read(address, data)
   task apb_read;
        input  [31:0] address;
        output [31:0]  data;
   begin
            @ (posedge PCLK);
            PSEL   <= #1 1'b1;
            PADDR  <= #1 address;
            PWRITE <= #1 1'b0;
            @ (posedge PCLK);
            PENABLE <= #1 1'b1;
            @ (posedge PCLK);
            PSEL    <= #1 1'b0;
            PENABLE <= #1 1'b0;
            PADDR   <= 0;
            data     = PRDATA; // must be blocking
   end
   endtask

   // generate a write transaction for 4 byte on AMBA APB
   // apb_write(address, data)
   task apb_write;
        input  [31:0] address;
        input  [31:0] data;
   begin
            @ (posedge PCLK);
            PSEL   <= #1 1'b1;
            PADDR  <= #1 address;
            PWRITE <= #1 1'b1;
            PWDATA <= #1 data;
            @ (posedge PCLK);
            PENABLE <= #1 1'b1;
            @ (posedge PCLK);
            PSEL    <= #1 1'b0;
            PENABLE <= #1 1'b0;
            PWRITE  <= #1 1'b0;
            PADDR   <= #1 0;
            PWDATA  <= #1 0;
   end
   endtask
`endif
