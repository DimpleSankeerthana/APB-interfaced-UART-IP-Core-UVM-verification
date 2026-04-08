`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

interface uart_if(input bit clk);

	logic Presetn;
	logic [31:0] Paddr;
	bit Psel;
	bit Pwrite;
	bit Penable;
	logic [31:0] Pwdata;
	logic [31:0] Prdata;
	logic Pready;
	logic Pslverr;
	bit IRQ;
	logic tx;
	logic rx;
	logic baud_o;
	
	clocking uart_drv_cb @(posedge clk);
		default input #1 output #1;
		output Presetn;
		output Paddr;
		output Psel;
		output Pwrite;
		output Penable;
		output Pwdata;
		input Pready;
		input Pslverr;
		input Prdata;
		input IRQ;
		input baud_o;
                output tx;
	//	output RXD;
	endclocking

	clocking uart_mon_cb @(posedge clk);
		default input #1 output #1;
		input Presetn;
		input Paddr;
		input Psel;
		input Pwrite;
		input Penable;
		input Pwdata;
		input Pready;
		input Pslverr;
		input Prdata;
		input tx;
                input rx;
		input baud_o;
		input IRQ;
	endclocking

	modport DRV_MP(clocking uart_drv_cb);
	modport MON_MP(clocking uart_mon_cb);

endinterface

interface apb_if(input logic clk);//------------------------------>>
        logic PRESETn;
        logic PENABLE;
        logic PSEL;
        logic [31:0] PADDR;
        logic [31:0] PWDATA;
        logic [31:0] PRDATA;
        logic PREADY;
        logic PWRITE;
        logic IRQ;
        logic PSLVERR;

        clocking apb_drv_cb @(posedge clk);
                output PRESETn;
                output PENABLE;
                output PSEL;
                output PADDR;
                output PWDATA;
                output PWRITE;
                input PREADY;///////////////////////////////////////////////////////// we use in drv input or output?
                input IRQ;
                input PSLVERR;
                input PRDATA;
        endclocking

        clocking apb_mon_cb @(posedge clk);
                input PRESETn;
                input PENABLE;
                input PSEL;
                input PADDR;
                input PWDATA;
                input PRDATA;
                input PREADY;
                input PWRITE;
                input PSLVERR;
                input IRQ;
         endclocking

        modport apb_drv_mp (clocking apb_drv_cb);
        modport apb_mon_mp (clocking apb_mon_cb);

endinterface

class apb_xtn extends uvm_sequence_item;//============================================>

        `uvm_object_utils(apb_xtn)

        function new(string name = "");
                super.new(name);
        endfunction

    bit PRESETn;
    bit PENABLE;
    bit PSEL;
    rand bit [31:0] PADDR;
    rand bit [31:0] PWDATA;
    bit [31:0] PRDATA;
    bit PREADY;
    rand bit PWRITE;
    bit PSLVERR;
    bit IRQ;

    bit dl_access; 
    bit data_in_thr; 
    bit data_in_rbr; 
    bit[7:0] lcr;
    bit[7:0] ier;
    bit[7:0] fcr;
    bit[15:0] div;
    bit[7:0] thr[$];
    bit[7:0] rbr[$];
    bit[7:0] iir;
    bit[7:0] lsr;

   constraint data_range{ PWDATA inside {[0:255]};} // constraint to restrict the data value to 8 bits as we are using 8 bit data width in our design

    function void do_print(uvm_printer printer);
        printer.print_field("Penable", this.PENABLE, 1, UVM_DEC);
        printer.print_field("Presetn", this.PRESETn, 1, UVM_DEC);
        printer.print_field("Psel", this.PSEL, 1, UVM_DEC);
        printer.print_field("Paddr", this.PADDR, 32,UVM_DEC);
        printer.print_field("Pwdata", this.PWDATA, 32, UVM_DEC);
        printer.print_field("PRdata", this.PRDATA, 32, UVM_DEC);
        printer.print_field("Pready", this.PREADY, 1,UVM_DEC);
        printer.print_field("Pwrite", this.PWRITE, 1, UVM_DEC);
        printer.print_field("PSLVERR", this.PSLVERR, 1, UVM_DEC);

        printer.print_field("LCR", this.lcr, 8, UVM_BIN);
        printer.print_field("IER", this.ier, 8, UVM_BIN);
        printer.print_field("FCR", this.fcr, 8, UVM_BIN);
        printer.print_field("DIV", this.div, 16, UVM_DEC);
        printer.print_field("THR", this.thr[thr.size()-1], 8, UVM_DEC); // printing the last value in thr array
        printer.print_field("RBR", this.rbr[rbr.size()-1], 8, UVM_DEC); // printing the last value in rbr array
        printer.print_field("IIR", this.iir, 8, UVM_BIN);
        printer.print_field("LSR", this.lsr, 8, UVM_BIN);
    endfunction


    function void do_copy(uvm_object rhs);
        apb_xtn rhs_;

        if(!$cast(rhs_, rhs))
            `uvm_error("ERROR", " casting failed in copy method")
        super.do_copy(rhs);
        this.PENABLE = rhs_.PENABLE;
        this.PRESETn = rhs_.PRESETn;
        this.PADDR = rhs_.PADDR;
        this. PRDATA =rhs_.PRDATA;
        this.PWDATA = rhs_.PWDATA;
        this.PWRITE = rhs_.PWRITE;
        this.PREADY = rhs_.PREADY;
    endfunction

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        apb_xtn rhs_;

        if(!$cast(rhs_, rhs))
            `uvm_error("ERROR", " casting failed in copy method")

        return
        super.do_compare(rhs,comparer) &&
        this.PENABLE == rhs_.PENABLE &&
        this.PRESETn == rhs_.PRESETn &&
        this.PADDR == rhs_.PADDR &&
        this. PRDATA ==rhs_.PRDATA &&
        this.PWDATA == rhs_.PWDATA &&
        this.PWRITE == rhs_.PWRITE &&
        this.PREADY == rhs_.PREADY;
    endfunction
endclass


class apb_conf extends uvm_object; 
        `uvm_object_utils(apb_conf)

        function new(string name = "");
                super.new(name);
        endfunction

        virtual apb_if vif;

endclass

class seq_base extends uvm_sequence#(apb_xtn);
    `uvm_object_utils(seq_base)

    function new(string name = "");
            super.new(name);
    endfunction
endclass

class apb_half_duplex_seq extends seq_base;

    `uvm_object_utils(apb_half_duplex_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000011;});
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;});
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

       // read_seq_h.start(m_sequencer);
    endtask
endclass

class apb_read_seq extends seq_base;  //-------------------------------------------------------------->
// based on the value of IIR register we are reading from registers

    `uvm_object_utils(apb_read_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        req = apb_xtn::type_id::create("req");

        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==0;}); //IIR register

        finish_item(req);
        get_response(req);    // getting the response from driver after reading IIR register and storing the value of IIR register in req item

        if(req.iir[3:0] == 4) // receiver data available interupt
        begin
            start_item(req);
            assert(req.randomize() with {PADDR == 32'h00; PWRITE==0;}); //Read from receiver buffer register
            finish_item(req);
        end

        if(req.iir[3:0] == 6) 
        begin
            start_item(req);
            assert(req.randomize() with {PADDR == 32'h14; PWRITE==0;}); //Read from line status register
            finish_item(req);
        end
    endtask
endclass


class apb_parity_error_seq extends seq_base; // to inject parity error and to verify whether it is getting reflected

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_parity_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00001011;});  //parity enabled and odd parity
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);


        read_seq_h.start(m_sequencer);
        
    endtask
endclass

class apb_framing_error_seq extends seq_base; // to inject framing error and to verify whether it is getting reflected

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_framing_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b00000111;});  //stop bit is made 1
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

        read_seq_h.start(m_sequencer);
        
    endtask
endclass

class apb_break_error_seq extends seq_base;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_break_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);

        read_seq_h.start(m_sequencer);
        
    endtask
endclass

class apb_overrun_error_seq extends seq_base;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_overrun_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;});
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000101;}); //line status interupt should be enabled to check parity error in line status register
        finish_item(req);

        //transmitter holding register
        repeat(17) begin
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h00; PWRITE==1;});
        finish_item(req);
        end

        read_seq_h.start(m_sequencer);
        
    endtask
endclass

class apb_thr_empty_error_seq extends seq_base; //dont configure thr and flush tx fifo

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_thr_empty_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");

        //divisor latch MSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b00000110;}); 
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000111;}); //trasmitter empty interupt enabled
        finish_item(req);

        read_seq_h.start(m_sequencer);
        
    endtask
endclass


class apb_timeout_error_seq extends seq_base;

     apb_read_seq read_seq_h;

    `uvm_object_utils(apb_timeout_error_seq)

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
        read_seq_h = apb_read_seq::type_id::create("read_seq_h");
                req = apb_xtn::type_id::create("req");


        start_item(req);
        assert(req.randomize() with {PADDR == 32'h20; PWRITE==1; PWDATA==0;});
        finish_item(req);

        //divisor latch LSB
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h1c; PWRITE==1; PWDATA==27;});
        finish_item(req);

        //line control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'hc; PWRITE==1; PWDATA==8'b01000011;});  //break control enabled (7th bit)
        finish_item(req);

        //fifo control register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h08; PWRITE==1; PWDATA==8'b11000110;}); // threshold 4 bytes
        finish_item(req);

        //interupt enable register
        start_item(req);
        assert(req.randomize() with {PADDR == 32'h04; PWRITE==1; PWDATA==8'b00000111;}); //trasmitter empty interupt enabled
        finish_item(req);
        
        read_seq_h.start(m_sequencer);
        
    endtask
endclass

class apb_loopback_seq extends seq_base;

    `uvm_object_utils(apb_loopback_seq)

    apb_half_duplex_seq half_duplex_h;
    apb_read_seq read_seq_h;

    function new(string name = "");
            super.new(name);
    endfunction

    task body();
       apb_half_duplex_seq half_duplex_h = apb_half_duplex_seq::type_id::create("half_duplex_h");
       apb_read_seq read_seq_h = apb_read_seq::type_id::create("read_seq_h");
        half_duplex_h.start(m_sequencer);
        read_seq_h.start(m_sequencer);
    endtask
endclass




class apb_drv extends uvm_driver#(apb_xtn);//------------------------------>>

        `uvm_component_utils(apb_drv)

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        apb_conf apb_conf_h;
        virtual apb_if.apb_drv_mp vif;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(apb_conf)::get(this, "", "apb_conf", apb_conf_h))
                        `uvm_fatal("APB_DRV", "Failed to get APB configuration")
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                vif = apb_conf_h.vif ;
        endfunction

        task run_phase(uvm_phase phase);
                @(vif.apb_drv_cb);
                vif.apb_drv_cb.PRESETn <= 0;
                @(vif.apb_drv_cb);
                vif.apb_drv_cb.PRESETn <= 1;

                forever begin
                        seq_item_port.get_next_item(req);
                        `uvm_info("APB_DRV", "\nReceived a transaction from sequence", UVM_MEDIUM)
                        req.print();
                        drive(req);
                        seq_item_port.item_done();
                end
        endtask

        task drive(apb_xtn req);

                @(vif.apb_drv_cb);
                vif.apb_drv_cb.PADDR <= req.PADDR;
                vif.apb_drv_cb.PWDATA <= req.PWDATA;
                vif.apb_drv_cb.PWRITE <= req.PWRITE;

                vif.apb_drv_cb.PENABLE <= 0;
                vif.apb_drv_cb.PSEL <= 1;

                @(vif.apb_drv_cb); 
                vif.apb_drv_cb.PENABLE <= 1;

                @(vif.apb_drv_cb); 

                while(!vif.apb_drv_cb.PREADY)                   // we declared pready in driver as input  we can use pready ready in vif
                        @(vif.apb_drv_cb);            // waits for the slave to be ready and moves to next line if asserted

                if(req.PADDR == 32'h8 && req.PWRITE == 0) 
                begin                                                 // IIR register
                        while(vif.apb_drv_cb.IRQ==0)                    //wait for the interrupt to be asserted
                                @(vif.apb_drv_cb);            

                        req.iir = vif.apb_drv_cb.PRDATA;

                        /*rsp = req.clone(); //declare handle when u use it
                        rsp.set_id_info(req);
                        rsp.PRDATA = vif.apb_drv_cb.PRDATA;

                        seq_item_port.put_response(rsp); */       
                        seq_item_port.put_response(req);
                end
                
                vif.apb_drv_cb.PENABLE <= 0;
                vif.apb_drv_cb.PSEL <= 0;

        endtask
endclass

class apb_mon extends uvm_monitor;//------------------------------>>
        `uvm_component_utils(apb_mon)
        apb_conf apb_conf_h;
        virtual apb_if.apb_mon_mp vif;
        uvm_analysis_port#(apb_xtn) mon_port;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
                mon_port = new("mon_port", this);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(apb_conf)::get(this, "", "apb_conf", apb_conf_h))
                        `uvm_fatal("APB_MON", "Failed to get APB configuration")
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                vif = apb_conf_h.vif;
        endfunction

        task run_phase(uvm_phase phase);
                forever begin
                        collect();
                end
        endtask

        task collect();
           apb_xtn xtn;
           xtn = apb_xtn::type_id::create("xtn");

           @(vif.apb_mon_cb);
                while( vif.apb_mon_cb.PENABLE != 1)         // wait for access phase to start
                        @(vif.apb_mon_cb);
                      @(vif.apb_mon_cb);
                begin
                      while(!vif.apb_mon_cb.PREADY)         // wait for the slave to be ready
                               
                            @(vif.apb_mon_cb);
                        
                            xtn.PADDR = vif.apb_mon_cb.PADDR;
                            xtn.PWRITE = vif.apb_mon_cb.PWRITE;
                            xtn.PREADY = vif.apb_mon_cb.PREADY;
                            xtn.PSLVERR = vif.apb_mon_cb.PSLVERR;
                            xtn.IRQ = vif.apb_mon_cb.IRQ;  
                            xtn.PENABLE = vif.apb_mon_cb.PENABLE;
                            xtn.PSEL = vif.apb_mon_cb.PSEL;
                            xtn.PRESETn = vif.apb_mon_cb.PRESETn;

                            if(vif.apb_mon_cb.PWRITE == 1)
                                xtn.PWDATA = vif.apb_mon_cb.PWDATA;
                            else
                                xtn.PRDATA = vif.apb_mon_cb.PRDATA;

                            if(xtn.PADDR == 32'hc && xtn.PWRITE == 1)   xtn.lcr = xtn.PWDATA;
                            if(xtn.PADDR == 32'h4 && xtn.PWRITE == 1)   xtn.ier = xtn.PWDATA;
                            if(xtn.PADDR == 32'h8 && xtn.PWRITE == 1)   xtn.fcr = xtn.PWDATA;
                            if(xtn.PADDR == 32'h14 && xtn.PWRITE == 0)  xtn.lsr = xtn.PRDATA;  // no need of condition to check iir becasuse
                                // we will read lsr only when we read iir and if iir value is 6 then only we will read lsr in our sequence so no need to
                                // check the value of iir register here in monitor because we are already checking the value of iir register
                                // in sequence before reading lsr register
                           
                            if(xtn.PADDR == 32'h1c && xtn.PWRITE == 1)  
                            begin
                                xtn.div[7:0] = xtn.PWDATA;
                                 xtn.dl_access = 1; 
                            end
                            if(xtn.PADDR == 32'h20 && xtn.PWRITE == 1)  
                            begin
                                xtn.div[15:8] = xtn.PWDATA;
                                 xtn.dl_access = 1; 
                            end

                            if(xtn.PADDR == 32'h0 && xtn.PWRITE == 1)  
                            begin
                                         xtn.thr.push_back(xtn.PWDATA[7:0]);
                                         xtn.data_in_thr = 1;
                            end

                            if(xtn.PADDR == 32'h0 && xtn.PWRITE == 0)   
                            begin
                                         xtn.rbr.push_back(xtn.PRDATA[7:0]);
                                         xtn.data_in_rbr = 1;
                            end

                            if(xtn.PADDR == 32'h8 && xtn.PWRITE == 0)  
                                begin
                                    while(!vif.apb_mon_cb.IRQ)                    //wait for the interrupt to be asserted
                                        @(vif.apb_mon_cb);
                                        xtn.iir = vif.apb_mon_cb.PRDATA;
                                       /* if(xtn.iir[3:0] == 6) 
                                        begin
                                            xtn.lsr = vif.apb_mon_cb.PRDATA;
                                        end*/
                        
                                end
                        mon_port.write(xtn);
                        `uvm_info("APB_MON", "\nSampling is done. Transaction written to port", UVM_MEDIUM)
                        xtn.print();
                end
        endtask
endclass

class apb_seqr extends uvm_sequencer#(apb_xtn);
        `uvm_component_utils(apb_seqr)
        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
endclass

class apb_agent extends uvm_agent;
        `uvm_component_utils(apb_agent)
        apb_drv apb_drv_h;
        apb_mon apb_mon_h;
        apb_seqr apb_seqr_h;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_drv_h = apb_drv::type_id::create("apb_drv_h",this);
                apb_mon_h = apb_mon::type_id::create("apb_mon_h",this);
                apb_seqr_h = apb_seqr::type_id::create("apb_seqr_h",this);
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                apb_drv_h.seq_item_port.connect(apb_seqr_h.seq_item_export);
        endfunction
endclass

class apb_agent_top extends uvm_env;
        `uvm_component_utils(apb_agent_top)

        apb_agent apb_agent_h;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_agent_h = apb_agent::type_id::create("apb_agent_h",this);
        endfunction
endclass


//============================================================================================

class uart_conf extends uvm_object; 
        `uvm_object_utils(uart_conf)

        function new(string name = "");
                super.new(name);
        endfunction

        virtual uart_if vif;

endclass

class env_conf extends uvm_object;
        `uvm_object_utils(env_conf)

        function new(string name = "");
                super.new(name);
        endfunction

        uart_conf uart_cfg;
        apb_conf apb_cfg;
endclass

// here uart top needs to send the data, here we are randomizing the data to be transmitted 
                //and also the configuration of line control register because based on the configuration of line control register 
                //the number of bits to be transmitted will be decided and also whether parity bit is there or not and
                // whether stop bit is 1 or 2. so we are declaring lcr register in our transaction class
                //and based on that we will decide the value of other variables in our sequence item
// earlier in apb side, we randamoised pwdata and that data is sent through tx pin using the logic which we write in rtl
// here we are randomizing tx pin of 8 bits 
//according to lcr we need to generate parity bit and stop bit

class uart_xtn extends uvm_sequence_item;
                

        `uvm_object_utils(uart_xtn)

        rand bit [7:0] tx;
         bit [7:0] rx;
        bit parity;
        rand bit stop_bit;
        bit bad_parity;

        bit[7:0] lcr; // will be configured directly from test class 
        int bits;

        function new(string name = "");
                super.new(name);
        endfunction

        function void do_print(uvm_printer printer);
                printer.print_field("TX", this.tx, 8, UVM_HEX);
                printer.print_field("RX", this.rx, 8, UVM_HEX);
                printer.print_field("Parity", this.parity, 1, UVM_DEC);
                printer.print_field("Stop Bit", this.stop_bit, 1, UVM_DEC);
                printer.print_field("Bad Parity", this.bad_parity, 1, UVM_DEC);
                printer.print_field("LCR", this.lcr, 8, UVM_BIN);
        endfunction


        function void post_randomize();
                bits = lcr[1:0]+5; // calculating the number of bits to be transmitted based on the value of lcr register
                                   // we are not considering lcr bit 4 and bit 5 while calculating parity why?
                if(bad_parity == 0)     begin
                        if(lcr[3]) begin
                        parity=0;
                        for(int i=0; i<bits; i++) begin
                                parity = parity ^ tx[i]; // calculating parity bit based on the value of tx and number of bits to be transmitted
                        end                             // xor --> 1 (odd ones)    xor --> 0 (even ones) 
                end
                end

                else begin      parity = ~parity; end   //what will be default parity? if is 0 then it will be 1 
        endfunction

endclass

class uart_base_seq extends uvm_sequence#(uart_xtn);
        `uvm_object_utils(uart_base_seq)

        bit [7:0] lcr;

        function new(string name = "");
                super.new(name);
        endfunction

        task body();
        // getting lcr configaration from config db which is set in test class 
//and storing it in local variable lcr to use it in other sequences which are extending this base sequence
                if(!uvm_config_db#(bit[7:0])::get(null, get_full_name(), "lcr", lcr))
                        `uvm_fatal("UART_BASE_SEQ", "Failed to get LCR value from config DB")
        endtask
endclass

class uart_half_duplex_seq extends uart_base_seq;
        `uvm_object_utils(uart_half_duplex_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr; // assigning the value of lcr which we got from config db to transaction variable lcr

                start_item(req);
                assert(req.randomize() with {stop_bit==1;}); 
                finish_item(req);
        endtask
endclass

class uart_full_duplex_seq extends uart_base_seq;
        `uvm_object_utils(uart_full_duplex_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {stop_bit == 1;}); 
                finish_item(req);
        endtask
endclass

class uart_parity_seq extends uart_base_seq;
        `uvm_object_utils(uart_parity_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                // we need to assign values to variables(lcr, bad_parity) in our transaction class 
                req.lcr = lcr;
                req.bad_parity = 1; // to inject parity error

                start_item(req);
                assert(req.randomize() with {stop_bit ==1;});
                finish_item(req);
        endtask
endclass


class uart_framing_seq extends uart_base_seq;
        `uvm_object_utils(uart_framing_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {stop_bit ==0;});
                finish_item(req);
        endtask
endclass


class uart_break_seq extends uart_base_seq; 
        `uvm_object_utils(uart_break_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;  //break interupt enable

                start_item(req);
                assert(req.randomize() with {stop_bit ==0; tx==0;});
                finish_item(req);
        endtask
endclass


class uart_overrun_seq extends uart_base_seq;
        `uvm_object_utils(uart_overrun_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                repeat(17) begin
                        start_item(req);
                        assert(req.randomize() with {stop_bit ==1;});
                        finish_item(req);
                end
        endtask
endclass

class uart_thr_empty_seq extends uart_base_seq;
        `uvm_object_utils(uart_thr_empty_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr;

                start_item(req);
                assert(req.randomize() with {tx ==0; stop_bit ==1;});
                finish_item(req);
        endtask
endclass

class uart_timeout_seq extends uart_base_seq;
        `uvm_object_utils(uart_timeout_seq)
        function new(string name = "");
                super.new(name);
        endfunction

        task body();
                super.body();
                req = uart_xtn::type_id::create("req");

                req.lcr = lcr; 

                start_item(req);
                assert(req.randomize() with {tx ==0; stop_bit ==1;});
                finish_item(req);
        endtask
endclass


class uart_drv extends uvm_driver#(uart_xtn);
        `uvm_component_utils(uart_drv)
        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
        virtual uart_if vif;
        uart_conf uart_cfg;
        bit[7:0] lcr;

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(uart_conf)::get(this,"", "uart_conf", uart_cfg))
                        `uvm_fatal("UART_DRV", "Failed to get UART interface from config DB")
                if(!uvm_config_db#(bit[7:0])::get(this, "", "lcr", lcr))
                        `uvm_fatal("UART_DRV", "Failed to get LCR value from config DB")

        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                vif = uart_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
        forever begin
                req = uart_xtn::type_id::create("req");
                seq_item_port.get_next_item(req);
                `uvm_info("UART_DRV", "\nReceived a transaction from sequence", UVM_MEDIUM)
                req.print();
                drive(req);
                seq_item_port.item_done();
        end
        endtask

        task drive(uart_xtn req);
                repeat(16) 
                        @(posedge vif.uart_drv_cb.baud_o);
                        vif.uart_drv_cb.tx <= 0;   //start bit

                repeat(16)
                        @(posedge vif.uart_drv_cb.baud_o);     

                for(int i=0; i<req.bits; i++)        //data bits
                        send_tx(req.tx[i]);             
                
                if(lcr[3]) // parity bit is there or not, if lcr bit 3 is 1 then parity bit is there
                    send_tx(req.parity);

                send_tx(req.stop_bit);  //stop bit

                // Additional wait for specific configurations
               if (lcr[2] == 1) begin
                        if (lcr[1:0] == 2'b00) begin
                                  repeat(8) @(posedge vif.uart_drv_cb.baud_o);
                end
        end
        endtask

        task send_tx(bit data_bit);
                vif.uart_drv_cb.tx <= data_bit;
                repeat(16)
                @(posedge vif.uart_drv_cb.baud_o);
        endtask
endclass

class uart_mon extends uvm_monitor;
        `uvm_component_utils(uart_mon)

        bit[7:0] lcr;
        virtual uart_if vif;
        uart_conf uart_cfg;
        uvm_analysis_port#(uart_xtn) mon_port;
        uart_xtn xtn;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(uart_conf)::get(this,"", "uart_conf", uart_cfg))
                        `uvm_fatal("UART_MON", "Failed to get UART interface from config DB")

                if(!uvm_config_db#(bit[7:0])::get(this, "", "lcr", lcr))
                        `uvm_fatal("UART_MON", "Failed to get LCR value from config DB")

                mon_port = new("mon_port", this);
                xtn = uart_xtn::type_id::create("xtn");
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                vif = uart_cfg.vif;
        endfunction

        task run_phase(uvm_phase phase);
                bit rx_busy, tx_busy;
                fork
                forever 
                    begin
                        if(rx_busy == 0) 
                           begin
                                rx_busy = 1;   // to avoid sampling of data bits when we are already in middle of receiving a data, we are using this rx_busy signal
                                collect(vif.rx, xtn.rx, xtn.parity); //uart ip core sending bits through tx and we are receiving through rx
                                                                //we will recive bit by bit through rx and we store it in rx of our transaction class(8bit)
                                rx_busy = 0;
                           end
                        else
                                @(posedge vif.baud_o);  
                    end
                
                forever 
                     begin
                        if(tx_busy == 0) // start bit of transmitting data
                           begin
                                tx_busy = 1;
                                
                                collect(vif.tx, xtn.tx, xtn.parity);
                                tx_busy = 0;
                           end
                        else
                                @(posedge vif.baud_o);
                     end
                join_none
        endtask 

        task collect(ref logic line, ref bit[7:0] data, ref bit parity);
               int bits;
               bits = lcr[1:0]+5; 

               /*wait(line==1);
               @(posedge vif.baud_o); 
               wait(line==0);    */                     // start bit

                @(negedge line);  // wait for the start bit
                $display("Start bit detected at time %0t", $time);

               repeat(24) @(posedge vif.baud_o);    // wait for the middle of the bit duration
               
               for(int i=0; i<bits; i++)                //data bits
               begin
                        $display("bit %0d sampled at time %0t", i, $time);
                        data[i] = line;
                        repeat(16) @(posedge vif.baud_o);
               end

               if(lcr[3])  
                 begin
                           parity = line;
                           $display("Parity bit sampled at time %0t", $time);
                           repeat(16) @(posedge vif.baud_o);
                 end

                 mon_port.write(xtn);
                 `uvm_info("UART_MON", "\nSampling is done. Transaction written to port", UVM_MEDIUM)
                 xtn.print();

        endtask
endclass

class uart_seqr extends uvm_sequencer#(uart_xtn);
        `uvm_component_utils(uart_seqr)
        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
endclass

class vseqr extends uvm_sequencer#(uvm_sequence_item);
        `uvm_component_utils(vseqr)

        apb_seqr apb_seqrh;
        uart_seqr uart_seqrh;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
endclass

class vseq extends uvm_sequence#(uvm_sequence_item);
        `uvm_object_utils(vseq)

        apb_seqr apb_seqrh; 
        uart_seqr uart_seqrh;
        //apb_seq apb_seqh;

        function new(string name = "");
                super.new(name);
        endfunction

                task body();
        //              apb_seqh = apb_seq::type_id::create("apb_seqh");
                endtask
endclass


class uart_agent extends uvm_agent;
        `uvm_component_utils(uart_agent)

        uart_drv uart_drv_h;
        uart_mon uart_mon_h;
        uart_seqr uart_seqr_h;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uart_drv_h = uart_drv::type_id::create("uart_drv_h",this);
                uart_mon_h = uart_mon::type_id::create("uart_mon_h",this);
                uart_seqr_h = uart_seqr::type_id::create("uart_seqr_h",this);
        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                uart_drv_h.seq_item_port.connect(uart_seqr_h.seq_item_export);
        endfunction

endclass

class uart_agent_top extends uvm_env;
        `uvm_component_utils(uart_agent_top)

        uart_agent uart_agent_h;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                uart_agent_h = uart_agent::type_id::create("uart_agent_h",this);
        endfunction
endclass

class sb extends uvm_scoreboard;
        `uvm_component_utils(sb)


        env_conf env_cfg;
        apb_xtn apb_xtn_h;
        uart_xtn uart_xtn_h;

        apb_xtn apb_iir_xtn_h;
        apb_xtn apb_cov;

        int thrlsize, rbrlsize;
        uvm_tlm_analysis_fifo#(apb_xtn) apb_fifo;   //apb write trans
        uvm_tlm_analysis_fifo#(uart_xtn) uart_fifo; //uart read trans

        covergroup apb_signals_cov;
                option.per_instance = 1;
                ADDRESS : coverpoint apb_cov.PADDR{
                        bins addr_0 = {32'h0};
                        bins addr_4 = {32'h4};
                        bins addr_8 = {32'h8};
                        bins addr_c = {32'hc};
                        bins addr_1c = {32'h1c};
                        bins addr_20 = {32'h20};
                }
                WRITE : coverpoint apb_cov.PWRITE {
                        bins write = {1};
                        bins read = {0};
                }
                DATA : coverpoint apb_cov.PWDATA {

                
                        bins data_0 = {[0:255]};
                }
        endgroup

        covergroup apb_lcr_cov;
                option.per_instance = 1;
                CHAR_SIZE : coverpoint apb_cov.lcr[1:0] {
                        bins five = {2'b00};
                        bins eight = {2'b11};
                }

                STOP_BIT : coverpoint apb_cov.lcr[2] {
                        bins one_stop_bit = {0};
                        bins two_stop_bit = {1};
                }

                PARITY_ENABLE: coverpoint apb_cov.lcr[3] {
                        bins parity_disabled = {0};
                        bins parity_enabled = {1};
                }

                EVEN_ODD_PARITY: coverpoint apb_cov.lcr[4] {
                        bins even_parity = {1};
                        bins odd_parity = {0};
                }
        endgroup

        covergroup apb_ier_cov;
                option.per_instance = 1;
                RECIVE_DATA_INT : coverpoint apb_cov.ier[0] {
                        bins rec_data_int_disabled = {0};
                        bins rec_data_int_enabled = {1};
                }
                THR_EMPTY_INT : coverpoint apb_cov.ier[1] {
                        bins thr_empty_int_disabled = {0};
                        bins thr_empty_int_enabled = {1};
                }
                LINE_STATUS_INT : coverpoint apb_cov.ier[2] {
                        bins line_status_int_disabled = {0};
                        bins line_status_int_enabled = {1};
                }
                IER_RST : coverpoint apb_cov.ier {
                        bins ier_reset = {0};
                }
        endgroup

        covergroup apb_fcr_cov;
                option.per_instance = 1;

                RX_FIFO_RST : coverpoint apb_cov.fcr[1] {
                        bins rx_fifo_not_rst = {0};
                        bins rx_fifo_rst = {1};
                }
                TX_FIFO_RST : coverpoint apb_cov.fcr[2] {
                        bins tx_fifo_not_rst = {0};
                        bins tx_fifo_rst = {1};
                }
                FIFO_TRIGGER_LEVEL : coverpoint apb_cov.fcr[7:6] {
                        bins level_1_byte = {2'b00};
                        bins level_4_byte = {2'b01};
                        bins level_8_byte = {2'b10};
                        bins level_14_byte = {2'b11};
                }
        endgroup

        covergroup apb_iir_cov;
                option.per_instance = 1;

                LINE_STATUS_INT: coverpoint apb_cov.ier {
                        bins line_status_int = {3'b110};
                }
                REC_DATA_INT: coverpoint apb_cov.ier {
                        bins rec_data_int = {3'b100};
                }
                THR_EMPTY_INT: coverpoint apb_cov.ier {
                        bins thr_empty_int = {3'b010};
                }
                TIMEOUT_INT: coverpoint apb_cov.ier {
                        bins timeout_int = {8'h0c};
                }

        endgroup

        covergroup apb_lsr_cov;
                option.per_instance = 1;

                DATA_READY: coverpoint apb_cov.lsr[0] {
                        bins data_not_ready = {0};
                        bins data_ready = {1};
                }
                THR_EMPTY: coverpoint apb_cov.lsr[5] {
                        bins thr_not_empty = {0};
                        bins thr_empty = {1};
                }
                 OVR_ERR: coverpoint apb_cov.lsr[1] {
                        bins no_overrun_error = {0};
                        bins overrun_error = {1};
                }
                 PARITY_ERR: coverpoint apb_cov.lsr[2] {
                        bins no_parity_error = {0};
                        bins parity_error = {1};
                }
                 FRM_ERR: coverpoint apb_cov.lsr[3] {
                        bins no_framing_error = {0};
                        bins framing_error = {1};
                }
                 BRK_INT: coverpoint apb_cov.lsr[4] {
                        bins no_break_interrupt = {0};
                        bins break_interrupt = {1};
                }
        endgroup

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
                apb_fifo = new("apb_fifo", this);
                uart_fifo = new("uart_fifo", this);
                apb_signals_cov = new();
                apb_lcr_cov = new();
                apb_ier_cov = new();
                apb_fcr_cov = new();
                apb_iir_cov = new();
                apb_lsr_cov = new();

        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
        endfunction

        task run_phase(uvm_phase phase);
           fork
                forever begin
                        apb_fifo.get(apb_xtn_h); //uart1
                        apb_cov = apb_xtn_h;
                        $display(" ################  SCORE BOARD #######################################################################################3#");
                        apb_xtn_h.print();
                        apb_signals_cov.sample(); // covergroup sampling
                        apb_lcr_cov.sample();
                        apb_ier_cov.sample();
                        apb_fcr_cov.sample();
                        apb_iir_cov.sample();
                        apb_lsr_cov.sample();

                        thrlsize = apb_xtn_h.thr.size();
                        rbrlsize = apb_xtn_h.rbr.size();

                        if(apb_xtn_h.PADDR == 32'h8 && apb_xtn_h.PWRITE == 0)
                                         apb_iir_xtn_h = apb_xtn_h;

                        `uvm_info("SB", "PRINTING APB TRANSACTION IN SCOREBOARD", UVM_LOW)
                        apb_xtn_h.print();

                end

                forever begin
                        uart_fifo.get(uart_xtn_h);//uart2
                        `uvm_info("SB", "PRINTING UART TRANSACTION IN SCOREBOARD", UVM_LOW)
                        uart_xtn_h.print();
                end
           join_none
        endtask


        function void check_phase(uvm_phase phase);
                if(apb_xtn_h == null) begin
                 `uvm_error("SB","apb_xtn_h is null")
                  return;
                end

                if(uart_xtn_h == null) begin
                        `uvm_error("SB","uart_xtn_h is null")
                        return;
                end
                 `uvm_info("SB", $sformatf("size of thr : %0d", thrlsize), UVM_LOW)
                `uvm_info("SB", $sformatf("size of rbr : %0d", rbrlsize), UVM_LOW)
                `uvm_info("SB", $sformatf(" APB : PRDATA : %0d", apb_xtn_h.PRDATA[7:0]), UVM_LOW)
                `uvm_info("SB", $sformatf(" APB : PWDATA : %0d", apb_xtn_h.PWDATA[7:0]), UVM_LOW)
                `uvm_info("SB", $sformatf("values send by UART1(APB)| thr : %p", apb_xtn_h.thr), UVM_LOW)
                `uvm_info("SB", $sformatf("values sent by UART2(UART) | tx : %p", uart_xtn_h.tx), UVM_LOW)
                `uvm_info("SB", $sformatf("values received by UART1(APB) | rbr : %p", apb_xtn_h.rbr), UVM_LOW)
                `uvm_info("SB", $sformatf("values received by UART2(UART) | rx : %p", uart_xtn_h.rx), UVM_LOW)
                `uvm_info("SB", $sformatf("values of iir register : %b", apb_iir_xtn_h.iir), UVM_LOW)
                if(apb_iir_xtn_h.iir[3:1] == 3'b010)  begin   //check whether receiver data interupt is there
                   //if(apb_xtn_h.mcr[4]==0) begin

                        if(apb_xtn_h.thr.size()==0) begin  // thr should ne empty
                                if((apb_xtn_h.PWDATA[7:0] == uart_xtn_h.rx) || (uart_xtn_h.tx==apb_xtn_h.PRDATA[7:0]))
                                begin
                                        $display("\n******************************************************************************************************");
                                        `uvm_info("SB", "half duplex comparision is successful", UVM_LOW)
                                        $display("********************************************************************************************************");
                                end

                                else
                                        begin
                                        $display("\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        `uvm_error("SB", "half duplex comparision failed")
                                        $display("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                                        end
                        end
                        else begin
                                if((apb_xtn_h.PWDATA[7:0] == uart_xtn_h.rx) && (uart_xtn_h.tx==apb_xtn_h.PRDATA[7:0]))
                                        `uvm_info("SB", "full duplex comparision is successful", UVM_LOW)
                                else
                                        `uvm_error("SB", "full duplex comparision failed")
                        end
                end

                if(apb_iir_xtn_h.iir[3:1] == 3) begin   //check whether transmitter empty interupt is there
                        if(apb_iir_xtn_h.lsr[1] == 1)   // check whether transmitter is empty or not
                                `uvm_info("SB", "overrun error occured", UVM_LOW)
                        if(apb_iir_xtn_h.lsr[2]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "parity error occured", UVM_LOW)
                        if(apb_iir_xtn_h.lsr[3]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "framing error occured", UVM_LOW)
                        if(apb_iir_xtn_h.lsr[4]==1)    // check whether transmitter is empty or not
                                `uvm_info("SB", "break interrupt occured", UVM_LOW)
                end

                if(apb_iir_xtn_h.iir[3:1] == 3'b110)    //check whether line status interupt is there
                         `uvm_info("SB", "time out error occured", UVM_LOW)
                 if(apb_iir_xtn_h.iir[3:1] == 3'b001)    //check whether line status interupt is there
                         `uvm_info("SB", "thr empty error occured", UVM_LOW)

        endfunction
endclass

class env extends uvm_env;
        `uvm_component_utils(env)

        apb_agent_top apb_agent_top_h;
        uart_agent_top uart_agent_top_h;
        sb sbh;
        vseqr vseqrh;
        env_conf env_cfg;
        apb_conf apb_cfg;
        uart_conf uart_cfg;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_agent_top_h= apb_agent_top::type_id::create("apb_agent_top_h",this);
                uart_agent_top_h= uart_agent_top::type_id::create("uart_agent_top_h",this);

                apb_cfg = apb_conf::type_id::create("apb_cfg");
                uart_cfg = uart_conf::type_id::create("uart_cfg");

                sbh = sb:: type_id::create("sbh",this);
                vseqrh = vseqr :: type_id::create("vseqrh", this);

                if(!uvm_config_db#(env_conf)::get(this, "", "env_cfg", env_cfg))
                        `uvm_fatal("ENV", "Failed to get environment configuration")
                apb_cfg = env_cfg.apb_cfg;
                uart_cfg = env_cfg.uart_cfg;

                uvm_config_db#(apb_conf)::set(this, "apb_agent_top_h*", "apb_conf", apb_cfg);
                uvm_config_db#(uart_conf)::set(this, "uart_agent_top_h*", "uart_conf", uart_cfg);

        endfunction

        function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                //vseqrh.apb_seqrh = apb_agent_top_h.apb_agent_h.apb_seqr_h;
                //vseqrh.uart_seqrh = uart_agent_top_h.uart_agent_h.uart_seqr_h;
                        apb_agent_top_h.apb_agent_h.apb_mon_h.mon_port.connect(sbh.apb_fifo.analysis_export);
                        uart_agent_top_h.uart_agent_h.uart_mon_h.mon_port.connect(sbh.uart_fifo.analysis_export);
        endfunction
endclass

class test extends uvm_test;
        `uvm_component_utils(test)
         apb_conf apb_cfg;
         uart_conf uart_cfg;
         env_conf env_cfg;
        env envh;
        vseq vseqh;


        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                envh= env::type_id::create("envh",this);
                vseqh = vseq::type_id::create("vseqh");
                apb_cfg = apb_conf::type_id::create("apb_cfg");
                uart_cfg = uart_conf::type_id::create("uart_cfg");
                env_cfg = env_conf::type_id::create("env_cfg");

                if(!uvm_config_db#(virtual apb_if)::get(this,"", "vif", apb_cfg.vif))
                        `uvm_fatal("TEST", "Failed to get APB interface from config DB")

                if(!uvm_config_db#(virtual uart_if)::get(this,"", "vif", uart_cfg.vif))
                        `uvm_fatal("TEST", "Failed to get UART interface from config DB")

                env_cfg.apb_cfg = apb_cfg;
                env_cfg.uart_cfg = uart_cfg;
                uvm_config_db#(env_conf)::set(this, "envh", "env_cfg", env_cfg);
                uvm_config_db#(bit[7:0])::set(this, "*", "lcr", 8'b00000011); // setting lcr value in config db to be used in sequence and driver                
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                uvm_top.print_topology();
        endfunction

        
endclass

class half_duplex_test extends test;
        `uvm_component_utils(half_duplex_test)

        apb_half_duplex_seq apb_half_duplex_h;
        uart_half_duplex_seq uart_half_duplex_h;
        apb_read_seq read_seqh;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_half_duplex_h = apb_half_duplex_seq::type_id::create("apb_half_duplex_h");
                uart_half_duplex_h = uart_half_duplex_seq::type_id::create("uart_half_duplex_h");
                read_seqh = apb_read_seq::type_id::create("read_seqh");
        endfunction
        
        task run_phase(uvm_phase phase);
                
                phase.raise_objection(this);
               // apb_half_duplex_h.start(envh.apb_agent_top_h.apb_agent_h.apb_seqr_h);
                uart_half_duplex_h.start(envh.uart_agent_top_h.uart_agent_h.uart_seqr_h);
              //  read_seqh.start(envh.apb_agent_top_h.apb_agent_h.apb_seqr_h);
                phase.drop_objection(this);
        endtask
endclass

module top;//---------------------------------------------------------------->

        bit clk1;
        bit clk2;

        int baud_cnt;
        bit PRESETn;
        apb_if apb_if_inst(clk1);
        uart_if uart_if_inst(clk2);

          uart_16550 dut (
    .PCLK    (clk1),
    .PRESETn (apb_if_inst.PRESETn),
    .PADDR   (apb_if_inst.PADDR),
    .PWDATA  (apb_if_inst.PWDATA),
    .PRDATA  (apb_if_inst.PRDATA),
    .PWRITE  (apb_if_inst.PWRITE),
    .PENABLE (apb_if_inst.PENABLE),
    .PSEL    (apb_if_inst.PSEL),
    .PREADY  (apb_if_inst.PREADY),
    .PSLVERR (apb_if_inst.PSLVERR),
    .IRQ     (apb_if_inst.IRQ),
    .TXD     (uart_if_inst.rx),
    .RXD     (uart_if_inst.tx),
    .baud_o  ()
    );

        always #5 clk2 = ~clk2;    //100MHz clock for UART
        always #10 clk1 = ~clk1;   //50MHz clock for APB

        // here manually assigning frequency without calculating 
        // we are not using divisor latch to give the value 54 just like we did for divisor latch in apb sequence(value 27)
        //instead we are writing logic to cout the number of baud pulses. here baud tick will be generated after every 54 clock cycles of 50MHz clock which is approximately equal to the baud rate of 115200. we are doing this because we are not using divisor latch to set the baud rate in our testbench and we want to generate baud tick for our UART VIP. if we use divisor latch to set the baud rate then we can directly use the divisor value to generate baud tick without counting the number of clock cycles.
        localparam int clk_freq = 100000000;                     //50MHz
        localparam int baud_rate = 115200;
        localparam int sample = 16;                           // oversampling by 16
        localparam int divisor = clk_freq/(sample*baud_rate); // divisor value for baud rate generation


        // reset sequence
        initial begin
                clk1 = 0;
                clk2 = 0;
                PRESETn = 0;
                #100 PRESETn = 1;
        end

       /* assign apb_if_inst.PRESETn = PRESETn;
        assign uart_if_inst.Presetn = PRESETn;*/        

        //GENERATE baud tick FOR UART VIP       
        always @(posedge clk2 or negedge PRESETn) begin
                if(!PRESETn) begin
                        baud_cnt <= 0;
                        uart_if_inst.baud_o <= 0;

                end else if (baud_cnt == divisor) begin  //till divisor value ?
                        uart_if_inst.baud_o <= 1;
                        baud_cnt <= 0;

                end else begin
                        uart_if_inst.baud_o <= 0;
                        baud_cnt <= baud_cnt +1;
                end

        end

        
        initial begin
                uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb_if_inst);
                uvm_config_db#(virtual uart_if)::set(null, "*", "vif", uart_if_inst);

                run_test("test");
        end
endmodule

