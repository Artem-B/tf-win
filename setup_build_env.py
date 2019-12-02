#! /usr/bin/python
# Run VsDevCmd.bat inside the baseline docker container and set
# the environment to its state after the batch file is run.
import argparse
import subprocess


def run_cmd(cmd):
    print("Running '%s'" % str(cmd))
    result = subprocess.run(cmd, stdout=subprocess.PIPE, check=True, shell=False)
    return result.stdout.decode('utf-8')


def make_docker_env(env):
    pass


def get_vsdevcmd_env(image, args):
    anchor = "=====ENV====="
    cmd = ["cmd", "/s", "/c", r'C:\BuildTools\Common7\Tools\VsDevCmd.bat'] + args
    cmd += ["&", "echo", anchor, "&", "set"]
    result = run_cmd(['docker', 'run', image] + cmd)
    _, env = result.split(anchor)
    # Got to change escape character to something other than backslash.
    # https://github.com/docker/for-win/issues/5254
    docker_env = ['# escape=`']
    for line in env.splitlines():
        if not line.strip():
            continue
        k, v = line.split('=', 1)
        docker_env.append("ENV %s %s" % (k, v))
    return docker_env

def get_container_for_image(image):
    #return run_cmd(['docker', 'container', 'ls', '-l', '-q', '-f', 'ancestor=%s' % image]).strip()
    return run_cmd(['docker', 'container', 'create', image]).strip()

def update_docker_image(image, output_image, base_container, env):
    args = []
    for line in env:
        args += ['-c', line]
    cmd = ['docker', 'commit'] + args + [base_container, output_image]
    result = run_cmd(cmd)
    print(result)



def main():
    parser = argparse.ArgumentParser(
        description='Set up build environment in the docker image')
    parser.add_argument("--output", default=None, help="Doutput image name.")
    parser.add_argument("--print", action="store_true",
                        default=False, help="Just print Dockerfile instructions")

    parser.add_argument('image',
                        help='an integer for the accumulator')

    parser.add_argument('args',  nargs='*', action="store",
                        default=["-arch=x64", "-host_arch=x64"],
                        help='Arguments to pass to VsDevCmd')

    args = parser.parse_args()
    output_image = args.output or args.image + "-x64"
    print(args.image, output_image, args.args)

    base_container = get_container_for_image(args.image)
    docker_env = get_vsdevcmd_env(args.image, args.args)
    if args.print:
        print("# Enviroment set by VsCmdArgs %s" % ' '.join(args.args))
        print("\n".join(docker_env))
        return
    update_docker_image(args.image, output_image, base_container, docker_env)
    pass

main()
