# CAMI: Using Docker Desktop (with `docker compose`)

## Troubleshooting WSL2 issues

### My distribution can't connect to the Docker Desktop

If you are using WSL2 and you can't connect to the Docker Desktop, you can try the following steps:

- Check if the Docker Desktop is running
- Check if Docker Desktop is enabled for the WSL2 distribution you are using. You can review these settings at `Settings > Resources > WSL Integration`

### I'm getting a `Permission denied @ dir_initialize` error for a directory that's mounted in a docker container 

If you are getting a `Permission denied @ dir_initialize` error when trying to mount a directory in a docker container, you can try the following steps:

- Check if your mounted directories are setup with `root:root` ownership permissions. Review [this SO issue](https://stackoverflow.com/a/73673569/3726759) for more details.
- Ensure that your WSL distribution user is in the docker group. You can add your user to the docker group by running the following command: `sudo usermod -aG docker $USER`
- Check the permissions of the directory you are trying to mount. You can use the `ls -l` command to check the permissions of the directory.
- If the directory is owned by root, you can change the ownership of the directory to your user by running the following command: `sudo chown -R $USER:$USER /path/to/directory`
- If the directory is owned by a different user, you can change the ownership of the directory to your user by running the following command: `sudo chown -R $USER:$USER /path/to/directory`
- If the directory is owned by a different group, you can change the ownership of the directory to your user by running the following command: `sudo chown -R $USER:$USER /path/to/directory`
- If the directory is owned by a different user and group, you can change the ownership of the directory to your user by running the following command: `sudo chown -R $USER:$USER /path/to/directory`