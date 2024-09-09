FROM public.ecr.aws/lambda/ruby:3.2

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ${LAMBDA_TASK_ROOT}/

# dependencies
RUN /bin/yum install wget unzip glibc -y
RUN wget https://github.com/duckdb/duckdb/releases/download/v1.1.0/libduckdb-linux-amd64.zip
RUN unzip libduckdb-linux-amd64.zip -d libduckdb && mv libduckdb/duckdb.* /usr/local/include/ && mv libduckdb/libduckdb.so /usr/local/lib
RUN /sbin/ldconfig --verbose /usr/local/lib

# Install Bundler and the specified gems
RUN gem install bundler:2.4.20 && \
    bundle config set --local path 'vendor/bundle' && \
    bundle install

# Copy function code
COPY lambda_function.rb ${LAMBDA_TASK_ROOT}/    

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_function.LambdaFunction::Handler.process" ]
