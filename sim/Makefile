cov_opt := line+cond+tgl+fsm

vcs_run:
	vcs -full64 -f filelist -sverilog -fsdb -debug_acc+all +v2k +notimingcheck +nospecify -l vcs_run.log -R -cm $(cov_opt)
vcs_cmp:
	vcs -full64 -sverilog +v2k -timescale=1ns/100ps +notimingcheck -debug_access+all +error+10000 +define+VCS_SIMULATOR+FUNCTIONAL -f filelist -l vcs_cmp.log
clean:
	rm -rf *.fsdb *.log novas.* simv simv.daidir verdiLog csrc ucli* both simv.vdb
verdi:
	verdi -f filelist -sverilog -ssf *.fsdb &
all: vcs_run verdi
urg:
	urg -dir simv.vdb -report both
