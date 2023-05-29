struct DiskLogger{T<:AbstractLogger} <: AbstractLogger
    logger::T
end

function DiskLogger(;
    loglevel::LogLevel = LogLevel(-1000),
    formatter::Function = default_disk_formatter,
    directory::String = pwd(),
    disk_groups::Dict{String, Vector{Symbol}} = Dict{String, Vector{Symbol}}(),
    data_groups::Tuple{Vararg{Symbol}} = (),
    exclude_group::Tuple{Vararg{Symbol}} = (:nosave,),
    exclude_module::Tuple{Vararg{Symbol}} = console_exclude_module,
)
    loggers = Vector{Union{FormatLogger,EarlyFilteredLogger}}()
    everything = formatter("$directory/all.log")
    remaining = formatter("$directory/default.log")
    push!(loggers, everything)
    for (name, groups) in disk_groups
        if name in ("default", "all")
            continue
        end
        sink = formatter("$directory/$name.log")
        grouped = EarlyFilteredLogger(sink) do log
            log.group ∈ groups ? true : false
        end
        remaining = EarlyFilteredLogger(remaining) do
            log.group ∉ groups ? true : false
        end
        push!(loggers, grouped)
    end
    push!(loggers, remaining)
    logger = TeeLogger(loggers...)
    logger = group_module_filter(logger, (exclude_group..., data_groups...), exclude_module)
    logger = MinLevelLogger(logger, loglevel)
    return DiskLogger(logger)
end

function default_disk_formatter(path::String)
    return FormatLogger(path) do io, args
        if length(args.kwargs |> keys) > 0
            println(io, "[", args.group, "/", args.level, "] - ", args.message, " ", args.kwargs |> values)
        else
            println(io, "[", args.group, "/", args.level, "] - ", args.message)
        end
    end
end

struct DataLogger{T<:AbstractLogger} <: AbstractLogger
    logger::T
end

function DataLogger(;
    loglevel::LogLevel = Logging.BelowMinLevel,
    directory::String = pwd(),
    formatter::Function = default_data_formatter,
    groups::Tuple{Vararg{Symbol}} = (),
)
    loggers = Vector{EarlyFilteredLogger}()
    for group ∈ groups
        file = formatter("$directory/$(group).data")
        logger = EarlyFilteredLogger(file) do log
            log.group ∈ groups ? true : false
        end
        push!(loggers, logger)
    end
    if length(loggers) > 0
        tee = TeeLogger(loggers...)
        logger = MinLevelLogger(tee, loglevel)
        return DataLogger(logger)
    end
    return nothing
end

function default_data_formatter(path::String)
    FormatLogger(path) do io, args
        if length(args.kwargs |> values) > 0
            println(io, args.message, " ", args.kwargs |> values)
        else
            println(io, args.message)
        end
    end
end
