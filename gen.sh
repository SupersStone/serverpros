# Copyright © 2023 OpenIM. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROTO_NAMES=(
    "auth"
    "conversation"
    "errinfo"
    "relation"
    "group"
    "jssdk"
    "msg"
    "msggateway"
    "push"
    "rtc"
    "sdkws"
    "third"
    "user"
    "statistics"
    "wrapperspb"
)

for name in "${PROTO_NAMES[@]}"; do
  # 获取proto文件中定义的go_package
  go_package=$(grep "option go_package" ${name}/${name}.proto | cut -d'"' -f2 | cut -d';' -f1)
  
  if [ -z "$go_package" ]; then
    # 如果没有找到go_package，使用默认值
    module_opt="--go_opt=module=github.com/SupersStone/serverpros/${name} --go-grpc_opt=module=github.com/SupersStone/serverpros/${name}"
  else
    # 如果找到go_package，使用它作为模块路径
    module=$(basename "$go_package")
    module_opt="--go_opt=module=${go_package} --go-grpc_opt=module=${go_package}"
  fi
  
  protoc --go_out=./${name} ${module_opt} --go-grpc_out=./${name} ${name}/${name}.proto
  if [ $? -ne 0 ]; then
      echo "error processing ${name}.proto"
      exit $?
  fi
done

if [ "$(uname -s)" == "Darwin" ]; then
    find . -type f -name '*.pb.go' -exec sed -i '' 's/,omitempty"`/\"\`/g' {} +
else
    find . -type f -name '*.pb.go' -exec sed -i 's/,omitempty"`/\"\`/g' {} +
fi