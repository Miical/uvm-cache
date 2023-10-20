`ifndef IN_ENV__SV
`define IN_ENV__SV

class in_env extends uvm_env;
    bus_agent i_agt;
    bus_agent o_agt;
    in_scoreboard scb;

    uvm_tlm_analysis_fifo #(bus_seq_item) agt_scb_fifo;

    function new(string name = "in_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        i_agt = bus_agent::type_id::create("i_agt", this);
        o_agt = bus_agent::type_id::create("o_agt", this);
        i_agt.is_active = UVM_ACTIVE;
        o_agt.is_active = UVM_PASSIVE;
        i_agt.tr_type = bus_seq_item::REQ;
        o_agt.tr_type = bus_seq_item::RESP;

        scb = in_scoreboard::type_id::create("scb", this);

        agt_scb_fifo = new("agt_scb_fifo", this);
    endfunction

    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(in_env)
endclass

function void in_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    o_agt.ap.connect(agt_scb_fifo.analysis_export);
    scb.act_port.connect(agt_scb_fifo.blocking_get_export);
endfunction

`endif
