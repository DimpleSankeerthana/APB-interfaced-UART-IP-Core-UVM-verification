
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
	logic TXD;
	logic RXD;
	logic baud_o;
	
	clocking drv_cb @(posedge clk);
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
	//	output RXD;
	endclocking

	clocking mon_cb @(posedge clk);
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
	//	input TXD;
		input baud_o;
		input IRQ;
	endclocking

	modport DRV_MP(clocking drv_cb);
	modport MON_MP(clocking mon_cb);

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
    bit data_in_rhr; 
    bit[7:0] lcr;
    bit[7:0] ier;
    bit[7:0] fcr;
    bit[15:0] div;
    bit[7:0] thr[$];
    bit[7:0] rhr[$];
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
        printer.print_field("RHR", this.rhr[rhr.size()-1], 8, UVM_DEC); // printing the last value in rhr array
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
                                         xtn.rhr.push_back(xtn.PRDATA[7:0]);
                                         xtn.data_in_rhr = 1;
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
class uart_xtn extends uvm_sequence_item;
        `uvm_object_utils(uart_xtn)
        function new(string name = "");
                super.new(name);
        endfunction
endclass

class uart_seq extends uvm_sequence#(uart_xtn);
        `uvm_object_utils(uart_seq)
        function new(string name = "");
                super.new(name);
        endfunction
endclass

class uart_drv extends uvm_driver#(uart_xtn);
        `uvm_component_utils(uart_drv)
        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
endclass

class uart_mon extends uvm_monitor;
        `uvm_component_utils(uart_mon)
        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction
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
        uart_seq uart_seqh;

        function new(string name = "");
                super.new(name);
        endfunction

                task body();
        //              apb_seqh = apb_seq::type_id::create("apb_seqh");
                        uart_seqh = uart_seq::type_id::create("uart_seq");
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


        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
        endfunction
endclass

class env extends uvm_env;
        `uvm_component_utils(env)

        apb_agent_top apb_agent_top_h;
        uart_agent_top uart_agent_top_h;
        sb sbh;
        vseqr vseqrh;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                apb_agent_top_h= apb_agent_top::type_id::create("apb_agent_top_h",this);
                uart_agent_top_h= uart_agent_top::type_id::create("uart_agent_top_h",this);
                sbh = sb:: type_id::create("sbh",this);
                vseqrh = vseqr :: type_id::create("vseqrh", this);

        endfunction
endclass

class test extends uvm_test;
        `uvm_component_utils(test)
         apb_conf cfg;
        env envh;
        vseq vseqh;
        apb_half_duplex_seq half_duplex_h;

        function new(string name = "",uvm_component parent);
                super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                envh= env::type_id::create("envh",this);
                vseqh = vseq::type_id::create("vseqh");
                cfg = apb_conf::type_id::create("cfg");
                half_duplex_h = apb_half_duplex_seq::type_id::create("half_duplex_h");

                if(!uvm_config_db#(virtual apb_if)::get(this,"", "vif", cfg.vif))
                        `uvm_fatal("TEST", "Failed to get APB interface from config DB");
                uvm_config_db#(apb_conf)::set(this, "*", "apb_conf", cfg);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
                uvm_top.print_topology();
        endfunction

        task run_phase(uvm_phase phase);
                super.run_phase(phase);
              //  vseqh.start(vseqrh);
                phase.raise_objection(this);
                half_duplex_h.start(envh.apb_agent_top_h.apb_agent_h.apb_seqr_h);
                #87000;
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
    .TXD     (uart_if_inst.TXD),
    .RXD     (uart_if_inst.RXD),
    .baud_o  ()
    );

        always #5 clk1 = ~clk1;    //100MHz clock for APB
        always #10 clk2 = ~clk2;   //50MHz clock for UART

        // here manually assigning frequency without calculating 
        // we are not using divisor latch to give the value 54 just like we did for divisor latch in apb sequence(value 27)
        //instead we are writing logic to cout the number of baud pulses. here baud tick will be generated after every 54 clock cycles of 50MHz clock which is approximately equal to the baud rate of 115200. we are doing this because we are not using divisor latch to set the baud rate in our testbench and we want to generate baud tick for our UART VIP. if we use divisor latch to set the baud rate then we can directly use the divisor value to generate baud tick without counting the number of clock cycles.
        localparam int clk_freq = 50000000;                     //50MHz
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

        assign apb_if_inst.PRESETn = PRESETn;
        assign uart_if_inst.Presetn = PRESETn;

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

                                                                                                                                                                                     