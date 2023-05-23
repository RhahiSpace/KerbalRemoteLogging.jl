shouldlog(logger::DataLogger, args...) = shouldlog(logger.logger, args...)
min_enabled_level(logger::DataLogger) = min_enabled_level(logger.logger)
catch_exceptions(logger::DataLogger) = catch_exceptions(logger.logger)
handle_message(logger::DataLogger, args...; kwargs...) = handle_message(logger.logger, args...; kwargs...)

shouldlog(logger::DiskLogger, args...) = shouldlog(logger.logger, args...)
min_enabled_level(logger::DiskLogger) = min_enabled_level(logger.logger)
catch_exceptions(logger::DiskLogger) = catch_exceptions(logger.logger)
handle_message(logger::DiskLogger, args...; kwargs...) = handle_message(logger.logger, args...; kwargs...)

function Base.close(logger::KerbalRemoteLogger)
    close(logger.message)
    close(logger.progress)
end

shouldlog(logger::KerbalRemoteLogger, args...) = shouldlog(logger.logger, args...)
min_enabled_level(logger::KerbalRemoteLogger) = min_enabled_level(logger.logger)
handle_message(logger::KerbalRemoteLogger, args...; kwargs...) = handle_message(logger.logger, args...; kwargs...)
catch_exceptions(logger::KerbalRemoteLogger) = catch_exceptions(logger.logger)
