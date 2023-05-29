struct KerbalRemoteLogger{T<:AbstractLogger} <: AbstractLogger
    message::TCPSocket
    progress::TCPSocket
    logger::T
end

"""
    KerbalRemoteLogger(; kwargs...)

RemoteLogger adapted for use with SpaceLib

- `disk_loglevel`: minimum log level to be saved to disk (if enabled)
- `disk_directory`: target destination for file logging. Use empty string to
  disable.
- `disk_formatter`: extra formatter for disk. It should be a function that
  accepts a path and combine it with a `FormatLogger`
- `disk_exclude_group`: log groups to ignore in disk.
- `console_exclude_module`: source modules to ignore in disk. Copies console by
  default.

- `data_loglevel`: minimum log level to save as csv.
- `data_directory`: target destination for data logging. Use empty string to
  disable.
- `data_formatter`: extra formatter for data. It should be a function that
  accepts a path and combine it with a `FormatLogger`
"""
function KerbalRemoteLogger(;
    host::IPAddr=IPv4(0),
    port::Integer=50003,
    timestring::Function=()->unix2datetime(time()),

    console_displaywidth::Integer=80,
    console_loglevel::LogLevel = LogLevel(-1),
    console_formatter::Union{Function, Nothing} = kerbal_formatter,
    console_exclude_group::Tuple{Vararg{Symbol}} = (:ProgressLogging,),
    console_exclude_module::Tuple{Vararg{Symbol}} = (:ProtoBuf,),

    disk_loglevel::LogLevel = LogLevel(-1000),
    disk_formatter::Function = kerbal_disk_formatter(timestring),
    disk_directory::String = "",
    disk_groups::Dict{String,Vector{Symbol}} = default_disk_group(),
    disk_exclude_group::Tuple{Vararg{Symbol}} = (:ProgressLogging,:nosave,),
    disk_exclude_module::Tuple{Vararg{Symbol}} = console_exclude_module,

    data_loglevel::LogLevel = Logging.BelowMinLevel,
    data_formatter::Function = kerbal_data_formatter(timestring),
    data_directory::String = disk_directory,
    data_groups::Tuple{Vararg{Symbol}} = (),
)
    disk_directory !== "" && mkpath(disk_directory)
    data_directory !== "" && mkpath(data_directory)
    remote = RemoteLogger(;
        host=host,
        port=port,
        displaywidth=console_displaywidth,
        loglevel=console_loglevel,
        formatter=console_formatter(timestring),
        exclude_group=(console_exclude_group..., data_groups...),
        exclude_module=console_exclude_module,
    )
    disk = nothing
    if disk_directory != ""
        disk = DiskLogger(;
            loglevel = disk_loglevel,
            formatter = disk_formatter,
            directory = disk_directory,
            disk_groups = disk_groups,
            exclude_group = (disk_exclude_group..., data_groups...),
            exclude_module = disk_exclude_module,
        )
    end
    data = nothing
    if data_directory != ""
        data = DataLogger(;
            loglevel = data_loglevel,
            directory = data_directory,
            formatter = data_formatter,
            groups = data_groups,
        )
    end
    combined = combine_loggers(remote, disk, data)
    return KerbalRemoteLogger(remote.message, remote.progress, combined)
end

function combine_loggers(remote, disk, data)
    isnothing(disk) && isnothing(data) && return remote
    isnothing(data) && return TeeLogger(remote, disk)
    isnothing(disk) && return TeeLogger(remote, data)
    return TeeLogger(remote, disk, data)
end

function kerbal_log_group(group, level)
    group |> dump |> println
    isnothing(group) && return (Warn ? "Warning" : string(level))
    return string(group)
end

function get_default_file_groups()
    Dict{String, Tuple{Vararg{Symbol}}}(
        "time" => (:time, ),
        "guidance" => (:guidance,),
        "system" => (:system,),
    )
end
