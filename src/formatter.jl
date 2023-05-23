function label(io::IO, msg)
    msg.group == :prototype   ? ungrouped(io, msg.level) :

    # Flight group / blue
    msg.group == :guidance    ? printstyled(io, " [GUIDO] "; color=4, bold=true) :
    msg.group == :gnc         ? printstyled(io, "   [GNC] "; color=4, bold=true) :
    msg.group == :dynamics    ? printstyled(io, "   [DYN] "; color=4, bold=true) :
    msg.group == :rangesafety ? printstyled(io, " [Range] "; color=4, bold=true) :
    msg.group == :rendezvous  ? printstyled(io, "  [RDNZ] "; color=4, bold=true) :
    msg.group == :trajectory  ? printstyled(io, "  [TRAJ] "; color=4, bold=true) :

    # Internals group / green
    msg.group == :eecom       ? printstyled(io, " [EECOM] "; color=2, bold=true) :
    msg.group == :prop        ? printstyled(io, "  [PROP] "; color=2, bold=true) :
    msg.group == :retro       ? printstyled(io, " [Retro] "; color=2, bold=true) :
    msg.group == :power       ? printstyled(io, " [Power] "; color=2, bold=true) :
    msg.group == :system      ? printstyled(io, "[System] "; color=2, bold=true) :
    msg.group == :module      ? printstyled(io, "[Module] "; color=2, bold=true) :

    # Programming group / red & magenta / grey
    msg.group == :develop     ? printstyled(io, "   [Dev] "; color=13, bold=true) :
    msg.group == :entry       ? printstyled(io, " [Entry] "; color=8, bold=true) :
    msg.group == :exit        ? printstyled(io, "  [Exit] "; color=8, bold=true) :
    msg.group == :controlloop ? printstyled(io, "[L-Ctrl] "; color=22, bold=true) :
    msg.group == :gncloop     ? printstyled(io, " [L-GNC] "; color=17, bold=true) :
    msg.group == :gui         ? printstyled(io, "   [GUI] "; color=5, bold=true) :
    msg.group == :graphic     ? printstyled(io, " [Graph] "; color=5, bold=true) :

    # Science group / white
    # msg.group == :telemetry   ? printstyled(io, " [Telem]") :

    # Status group / cyan-yellow-red
    msg.group == :status      ? label_status(io, msg.level) :
    msg.group == :mark        ? printstyled(io, "  [Mark] "; color=11, bold=true) :
    # Misc
    msg.group == :time        ? printstyled(io, "  [Time] "; color=8,  bold=true) :
    printstyled(io, lpad("[$(first(titlecase(string(msg.group)), 6))] ", 9); color=8, bold=true)
end

function label_status(io::IO, level::LogLevel)
    level ≥ LogLevel(2000) ? printstyled(io, "[Status] "; color=1, bold=true) :
    level ≥ LogLevel(1000) ? printstyled(io, "[Status] "; color=3, bold=true) :
    level ≥ LogLevel(0)    ? printstyled(io, "[Status] "; color=14, bold=true) :
    printstyled(io, "[Status] "; color=8, bold=true)
end

function ungrouped(io::IO, level::LogLevel)
    level ≥ LogLevel(2000) ? printstyled(io, " [Error] "; color=1, bold=true) :
    level ≥ LogLevel(1000) ? printstyled(io, "  [Warn] "; color=3, bold=true) :
    level ≥ LogLevel(0)    ? printstyled(io, "  [Info] "; color=7, bold=true) :
    printstyled(io, " [Debug] "; color=8, bold=true)
end

function levelcolor(level::LogLevel)
    level ≥ LogLevel(2000) ? 9 :
    level ≥ LogLevel(1000) ? 3 :
    level ≥ LogLevel(0) ? 7 : 8
end

function kerbal_formatter(timestring::Function)
    return (ioc::IOContext) -> begin
        FormatLogger(ioc) do io, args
            body = levelcolor(args.level)
            printstyled(io, timestring(), " "; color=body)
            label(io, args)
            kwargs = args.kwargs |> values
            if length(kwargs) > 0
                printstyled(io, args.message, "\n"; color=body)
                for (k, v) ∈ kwargs
                    printstyled(io, "  $k = $v\n"; color=body)
                end
            else
                printstyled(io, args.message, "\n"; color=body)
            end
        end
    end
end

function kerbal_disk_formatter(timestring::Function)
    return (path::String) -> begin
        FormatLogger(path) do io, args
            if length(args.kwargs |> keys) > 0
                println(io, timestring(), " [", args.group, "/", args.level, "] - ", args.message, " ", args.kwargs |> values)
            else
                println(io, timestring(), " [", args.group, "/", args.level, "] - ", args.message)
            end
        end
    end
end

function kerbal_data_formatter(timestring::Function)
    return (path::String) -> begin
        FormatLogger(path) do io, args
            if length(args.kwargs |> values) > 0
                println(io, timestring(), "|", args.message, "|", args.kwargs |> values)
            else
                println(io, timestring(), "|", args.message)
            end
        end
    end
end
