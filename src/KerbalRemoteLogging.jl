module KerbalRemoteLogging

using Dates
using Logging
using LoggingExtras
using RemoteLogging
using Sockets
using RemoteLogging: group_module_filter, root_module
import Base.CoreLogging:
    AbstractLogger, SimpleLogger,
    handle_message, shouldlog, min_enabled_level, catch_exceptions

export DiskLogger, DataLogger, KerbalRemoteLogger

include("diskloggers.jl")
include("formatter.jl")
include("logger.jl")
include("boilerplates.jl")

end
