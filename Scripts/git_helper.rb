class GitHelper
    def self.current_commit
        `git rev-parse --verify --long HEAD`.strip
    end

    def self.current_branch
        branch = `git rev-parse --abbrev-ref HEAD`.strip
        if branch == "HEAD"
            branch = `git describe --tags`.strip
        end
        return branch
    end
end
