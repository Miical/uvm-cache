`ifndef TOP_ENV__SV
`define TOP_ENV__SV

class top_env extends uvm_env;

    in_env  i_env;
    mem_env m_env;
    cache_model refmodel;

    uvm_tlm_analysis_fifo #(bus_seq_item) i_agt_model_fifo;
    uvm_tlm_analysis_fifo #(bus_seq_item) i_model_scb_fifo;
    uvm_tlm_analysis_fifo #(bus_seq_item) m_agt_model_fifo;
    uvm_tlm_analysis_fifo #(bus_seq_item) m_model_scb_fifo;

    function new(string name = "cache_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        i_env = in_env::type_id::create("i_env", this);
        m_env = mem_env::type_id::create("m_env", this);
        refmodel = cache_model::type_id::create("refmodel", this);

        i_agt_model_fifo = new("i_agt_model_fifo", this);
        i_model_scb_fifo = new("i_model_scb_fifo", this);
        m_agt_model_fifo = new("m_agt_model_fifo", this);
        m_model_scb_fifo = new("m_model_scb_fifo", this);
    endfunction

    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(top_env)
endclass

function void top_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    i_env.i_agt.ap.connect(i_agt_model_fifo.analysis_export);
    refmodel.in_port.connect(i_agt_model_fifo.blocking_get_export);
    refmodel.in_ap.connect(i_model_scb_fifo.analysis_export);
    i_env.scb.exp_port.connect(i_model_scb_fifo.blocking_get_export);

    m_env.i_agt.ap.connect(m_agt_model_fifo.analysis_export);
    refmodel.mem_port.connect(m_agt_model_fifo.blocking_get_export);
    refmodel.mem_ap.connect(m_model_scb_fifo.analysis_export);
    m_env.scb.exp_port.connect(m_model_scb_fifo.blocking_get_export);
endfunction

`endif
